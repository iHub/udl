class ScrapePage < ActiveRecord::Base
	
	attr_accessor :scrape_frequency_select

	#associations
	belongs_to  :scrape_session, counter_cache: true	
	has_many    :fb_posts, 		dependent: :destroy
	has_many	:fb_comments, :through => :fb_posts

	default_scope -> { order('created_at DESC') }
	scope 	:continuous, 	-> { where(continous_scrape: true) }
	scope 	:has_override,  -> { where(override_session_settings: true) }
	scope 	:no_override,   -> { where(override_session_settings: false) }

	#---------------------------

	SCRAPE_FREQUENCY_DEFAULT  = 600
	CONTINUOUS_SCRAPE_DEFAULT = false
	OVERRIDE_SESSION_DEFAULT  = false

	#---------------------------

	before_validation :clean_page_url, :set_page_type, :get_fb_page_id, on: :create
	# before_validation 
	# before_create	  :get_fb_page_id

	before_create   :set_defaults
	before_save     :set_next_scrape_date

	#---------------------------

	validates :page_url, 	presence: true
	validates_uniqueness_of	:page_url,   scope: :scrape_session_id, message: "This page exists in this sesssion!!"

	validates_presence_of   :fb_page_id, message: "Invalid URL!"
	validates_uniqueness_of	:fb_page_id, scope: :scrape_session_id

	validates :page_type,  presence: true
	validates :scrape_frequency, 	presence: true, if: :continous_scrape?, 
									numericality:  {only_integer: true}


	def total_posts
		self.fb_posts.size
	end

	def total_comments
		self.fb_comments.size
	end
	
	def epoch_time(standard_date_time)
		standard_date_time.to_time.utc.to_i
	end

	def get_fb_page_id
		logger.debug "inside get_fb_page_id"

		if page_type == "page" 

			begin
				# graph 		    = Koala::Facebook::API.new(fb_app_access_token)
				logger.debug "graph check next"
				@page_profile    = fb_graph.get_object(page_url)
			rescue Exception => e 				# swap Koala::Facebook::APIError
				logger.debug "e.inspect => #{e.inspect}"
				logger.debug "e.class => #{e.class}"
				logger.debug "e => #{e}"
				self.errors.add(:page_url, "#{e.message}")
			end

			logger.debug "graph called  ::  @page_profile => #{@page_profile.inspect}"

			if @page_profile.nil? 
				logger.debug "it's nil @page_profile => #{@page_profile.inspect}"
				self.errors.add(:page_url, "Invalid URL!!" )
			else
				self.fb_page_id = @page_profile["id"].to_s
				logger.debug "graph called  ::  fb_page_id => #{fb_page_id.inspect}"
			end
			

		elsif self.page_type == "group"
			crawl_and_get_id page_url
		end
		logger.debug "get_fb_page_id complete fb_page_id => #{fb_page_id.inspect}"

		self.fb_page_id
	end

	def crawl_and_get_id(fb_url_stub)
		group_id_reg_ex = /^(groups)\/((\d+)\/?\s*)(\/.*)?\s*$/
		group_id_match  = fb_url_stub.match group_id_reg_ex
		if group_id_match
			self.fb_page_id = group_id_match[3].to_s
		else
			# do a nokogiri scrape
		end
	end

	def clean_page_url
		self.page_url = page_url.gsub(/.*(facebook.com)[\/]/, '')
		logger.debug "clean_page_url called:: page_url => #{page_url}"
	end

	def set_page_type
		self.page_type =  page_url =~ /(groups)\// ? "group" : "page"
		logger.debug "set_page_type called :: page_type => #{page_type}"
	end


	########################################################

	def regular_scrape(start_date, end_date)
		logger.debug ">>>>>>>>>>> Running regular_scrape <<<<<<<<<<<<"
		logger.debug "Current Page => #{page_url}"
		
		@saved_posts  	 = []
		@comment_count   = 0
		@saved_comments  = []

		regular_scrape_start_time = Time.now			# for the logs
		@last_result_created_time = end_date

		get_fb_posts start_date, end_date, true
		regular_scrape_posts = FbPost.regular_post
		logger.debug "Total Posts => #{regular_scrape_posts.count}"
		get_fb_comments regular_scrape_posts

		regular_scrape_end_time = Time.now			# for the logs
	end
	handle_asynchronously :regular_scrape, priority: 20, queue: "regular_scrape"


	def retro_scrape(start_date, end_date)

		# start_date   = epoch_time self.initial_scrape_start        # convert date to unix epoch time
		# end_date     = epoch_time self.initial_scrape_end
		logger.debug ">>>>>>>>>>> Running retro scrape <<<<<<<<<<<<"
		
		@saved_posts  	 = []
		@comment_count   = 0
		@saved_comments  = []

		retro_scrape_start_time = Time.now			# for the logs
		@last_result_created_time = end_date

		
		get_fb_posts start_date, end_date, false

		logger.debug "get_fb_posts complete =>> get_fb_comments"

		get_fb_comments @saved_posts

		logger.debug "get_fb_comments complete"
		retro_scrape_end_time = Time.now			# for the logs
	end
	handle_asynchronously :retro_scrape, priority: 20, queue: "retro_scrape"


	#---------------------------------------------------

	# handle fb posts > get and save

	def get_fb_posts(start_date, end_date, regular_post)

		logger.debug "============ Running get_fb_posts ==============="

		logger.debug "start_date #{start_date} "
		logger.debug "end_date #{end_date} "
		query_limit  = 500
		posts_fql_query = "SELECT post_id, message, created_time FROM stream WHERE source_id = '#{self.fb_page_id}' AND message != '' AND created_time > #{start_date} AND created_time < #{end_date} LIMIT #{query_limit}"
		logger.debug "posts_fql_query => #{posts_fql_query}"

		fb_posts = fb_graph.fql_query(posts_fql_query)

		if !fb_posts.empty?
		    
		    logger.debug "----- Before Save ----------"
		    logger.debug "fb_posts.inspect => #{fb_posts.inspect}"

		    save_fb_posts fb_posts, regular_post

		    logger.debug "@last_result_created_time => #{@last_result_created_time}"
		    logger.debug "start_date => #{start_date}"
		    logger.debug "end_date => #{end_date}"

		    if @last_result_created_time > start_date
		        logger.debug "@last_result_created_time < start_date => true"
		        logger.debug "@last_result_created_time => #{@last_result_created_time} vs start_date => #{start_date}"
		        get_fb_posts start_date, @last_result_created_time, regular_post
		    end

		elsif fb_posts.empty?
		    logger.debug "###################### fb_posts is Empty!"
		end
	end


	def save_fb_posts(fb_posts, regular_post)
		logger.debug "_________________ save_fb_posts ____________________"
		logger.debug "fb_posts.nil? => #{fb_posts.nil?}"


		fb_posts.each do |fb_post|
		    this_post = {}
		    this_post[:fb_post_id] 	    = fb_post["post_id"]
		    this_post[:created_time] 	= Time.at(fb_post["created_time"]).utc
		    this_post[:message] 		= fb_post["message"]
		    this_post[:fb_page_id] 		= self.fb_page_id
		    this_post[:scrape_page_id]  = self.id
		    this_post[:regular_post]	= regular_post
		    
		    current_post = FbPost.new(this_post)

		    this_post_created_at = (current_post.created_time).to_time.utc.to_i

		    @last_result_created_time = this_post_created_at

		    logger.debug "@last_result_created_time => #{@last_result_created_time}"

		    # if @last_result_created_time <  this_post_created_at
		    #     @last_result_created_time = this_post_created_at
		    # end

		    if current_post.save
		    	@saved_posts << current_post
		        logger.debug "!!!!!!!!!!!!!!!!!! Record Saved !!!!!!!!!!!!!!!!!!"
		    else
		    	logger.debug "--------------- Record NOT Saved | possible duplicate -----------------"
		    end
		end

		logger.debug "**************** save_fb_posts complete ****************"

	end

	#---------------------------------------------------
	# handle fb comments > get and save
	#---------------------------------------------------

	def get_fb_comments(selected_posts)
		logger.debug "<<<<<<<<<<<< Running get_fb_comments  >>>>>>>>>>>"

		logger.debug "Page => #{page_url} >>> selected_posts.size => #{selected_posts.size}"
		return false if selected_posts.size == 0

		

		selected_posts.each do |current_fb_post|

			logger.debug "going through each post from selected_posts"

			logger.debug "perform graph search on current_fb_post from selected_posts"

			fb_post_graph_object = fb_graph.get_object(current_fb_post.fb_post_id, :fields => "comments.fields(comments.fields(from,message,created_time),message,from,created_time).limit(1000)")
			
			logger.debug "graph complete on current_fb_post"
			logger.debug "fb_post_graph_object => #{fb_post_graph_object.inspect}"
			logger.debug "pass graph query result to save_fb_comments"

			if !fb_post_graph_object["comments"].nil?
		    	save_fb_comments current_fb_post, fb_post_graph_object
		    else
		    	logger.debug "fb_post_graph_object[\"comments\"].nil? => #{fb_post_graph_object["comments"].nil?} "
			end
		end
		logger.debug "comment count => #{@comment_count}"
		logger.debug "saved_comments => #{@saved_comments.length}"
	end

	def save_fb_comments(fb_post, fb_post_graph_object)

        fb_post_graph_object["comments"]["data"].each do |comment|
            this_comment = {}
            this_comment[:comment_id]      = comment["id"]
            this_comment[:message]         = comment["message"]
            this_comment[:from_user_id]    = comment["from"]["id"]
            this_comment[:from_user_name]  = comment["from"]["name"]
            this_comment[:created_time]    = comment["created_time"]
            this_comment[:fb_post_id]      = fb_post.id
            this_comment[:parent_id]       =  "0"

            fb_comment = fb_post.fb_comments.build(this_comment)

            @comment_count +=1  

            if fb_comment.save
              @saved_comments << fb_comment
              logger.debug "SAVED.-"
            else
              logger.debug "<><><><><><> NOT SAVED.possible duplicate <><><><><><>"
            end

            # grab nested comments
            if !comment["comments"].nil? 
				comment["comments"]["data"].each do |comment_reply|
					nested_comment = {}
					nested_comment[:comment_id]      = comment_reply["id"]
					nested_comment[:message]         = comment_reply["message"]
					nested_comment[:from_user_id]    = comment_reply["from"]["id"]
					nested_comment[:from_user_name]  = comment_reply["from"]["name"]
					nested_comment[:created_time]    = comment_reply["created_time"]
					nested_comment[:fb_post_id]      = fb_post.id
					nested_comment[:parent_id]       = this_comment[:comment_id]

					fb_nested_comment = fb_post.fb_comments.build(nested_comment)

					@comment_count +=1

					if fb_nested_comment.save
						 @saved_comments << fb_nested_comment
						logger.debug "SAVED--"
					else
						logger.debug "<><><><><><> Nested Comment not SAVED. Possible Duplicate <><><><><><>"
					end
				end
            end

        end
        logger.debug "save_fb_comments >>> fb_post_graph_object processing complete"
	end

	#---------------------------------------------------

	private

		def fb_graph
			logger.debug "inside fb_graph"
			@fb_graph ||= Koala::Facebook::API.new(fb_app_access_token)
		end

		def fb_app_access_token
			logger.debug "getting the access token"
			@fb_app_access_token ||= AppSetting.last.fb_app_access_token
		end

		def set_defaults
			self.scrape_frequency  = SCRAPE_FREQUENCY_DEFAULT  if scrape_frequency == nil
			self.continous_scrape  = CONTINUOUS_SCRAPE_DEFAULT if continous_scrape == nil
			self.override_session_settings = OVERRIDE_SESSION_DEFAULT if override_session_settings == nil
		end

		def set_next_scrape_date	
			self.scrape_frequency  = SCRAPE_FREQUENCY_DEFAULT if scrape_frequency == nil
			self.next_scrape_date  = Time.now + scrape_frequency
		end
end
