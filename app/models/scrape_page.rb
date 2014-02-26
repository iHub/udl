class ScrapePage < ActiveRecord::Base

	default_scope -> { order('created_at DESC') }
	scope 	:continuous, 	-> { where(continous_scrape: true) }
	scope 	:has_override,  -> { where(override_session_settings: true) }
	scope 	:no_override,   -> { where(override_session_settings: false) }

	#-------------------------------------------------------------------------

	SCRAPE_FREQUENCY_DEFAULT  = 600
	CONTINUOUS_SCRAPE_DEFAULT = false
	OVERRIDE_SESSION_DEFAULT  = false

	#-------------------------------------------------------------------------

	attr_accessor :scrape_frequency_select

	#-------------------------------------------------------------------------

	belongs_to  :scrape_session, counter_cache: true	
	has_many    :fb_posts, 		dependent: :destroy
	has_many	:fb_comments, :through => :fb_posts

	#-------------------------------------------------------------------------

	validates :page_url, 	presence: true
	validates_uniqueness_of	:page_url,   scope: :scrape_session_id, message: "This page exists in this sesssion!!"

	validates_presence_of   :fb_page_id, message: "Invalid URL!"
	validates_uniqueness_of	:fb_page_id, scope: :scrape_session_id

	validates :page_type,  presence: true
	validates :user_id,  presence: true
	validates :scrape_frequency, 	presence: true, if: :continous_scrape?, 
									numericality:  {only_integer: true}


	#-------------------------------------------------------------------------

	before_validation :page_setup, on: :create
	before_save       :set_next_scrape_date

	#-------------------------------------------------------------------------


	def total_posts
		self.fb_posts_count
	end

	def total_comments
		self.fb_comments.size
	end
	
	def added_by

		added_by_user = User.find(self.user_id)	|| NullUser.new
		added_by_user.username
	end

	def epoch_time(standard_date_time)
		standard_date_time.to_time.utc.to_i
	end

	#-------------------------------------------------------------------------

	def regular_scrape(start_date, end_date)

		@saved_posts  	 = []
		@comment_count   = 0
		@saved_comments  = []
		@rejected_comments  = 0
		@rejected_posts  	= 0

		regular_scrape_start_time = Time.now			# for the logs
		@last_result_created_time = end_date

		get_fb_posts start_date, end_date, true
		
		regular_scrape_posts = FbPost.regular_post

		get_fb_comments regular_scrape_posts

		# update settings for next scrape
		session_next_scrape_date = Time.now + self.scrape_session.session_scrape_frequency
		next_scrape_date 		 = Time.now + scrape_frequency
		
		self.update_attributes(next_scrape_date: next_scrape_date)
		self.scrape_session.update_attributes(session_next_scrape_date: session_next_scrape_date)

		regular_scrape_end_time = Time.now			# for the logs
	end
	handle_asynchronously :regular_scrape, priority: 10, queue: "regular_scrape"


	def retro_scrape(start_date, end_date)
		
		@saved_posts  	 	= []
		@comment_count   	= 0
		@saved_comments  	= []
		@rejected_comments  = 0
		@rejected_posts  	= 0

		retro_scrape_start_time = Time.now			# for the logs
		@last_result_created_time = end_date

		get_fb_posts start_date, end_date, false

		logger.debug "@saved_posts.length => #{@saved_posts.length}"

		get_fb_comments @saved_posts

		logger.debug "@rejected_comments => #{@rejected_comments}"
		logger.debug "@rejected_posts    => #{@rejected_posts}"
		logger.debug "-------------- Post Stats -----------------"
		retro_scrape_end_time = Time.now			# for the logs
	end
	handle_asynchronously :retro_scrape, priority: 20, queue: "retro_scrape"


	#---------------------------------------------------

	# handle fb posts > get and save

	def get_fb_posts(start_date, end_date, regular_post = true)

		logger.debug "Get FB Posts "

		query_limit  = 500
		posts_fql_query = "SELECT post_id, message, created_time, updated_time FROM stream WHERE source_id = '#{self.fb_page_id}' AND message != '' AND created_time > #{start_date} AND created_time < #{end_date} LIMIT #{query_limit}"


		fb_posts = fb_graph.fql_query(posts_fql_query)

		if !fb_posts.empty?
		    save_fb_posts fb_posts, regular_post

		    if @last_result_created_time > start_date
		        
		        get_fb_posts start_date, @last_result_created_time, regular_post
		    end

		elsif fb_posts.empty?
		   
		end
	end


	def save_fb_posts(fb_posts, regular_post)

		fb_posts.each do |fb_post|
		    this_post = {}
		    this_post[:fb_post_id] 	    = fb_post["post_id"]
		    this_post[:created_time] 	= Time.at(fb_post["created_time"]).utc
		    this_post[:message] 		= fb_post["message"]
		    this_post[:updated_time] 	= Time.at(fb_post["updated_time"]).utc
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
		    else
		    	@rejected_posts += 1
		    	logger.debug "--------------- Record NOT Saved #{current_post.errors.full_messages}"
		    end
		end


	end

	#-------------------------------------------------------------------------
	# handle fb comments > get and save
	#-------------------------------------------------------------------------

	def get_fb_comments(selected_posts)
		
		return false if selected_posts.size == 0

		selected_posts.each do |current_fb_post|

			fb_post_graph_object = fb_graph.get_object(current_fb_post.fb_post_id, :fields => "updated_time,comments.fields(comments.fields(from,message,created_time),message,from,created_time).limit(500)")
	
			if !fb_post_graph_object["comments"].nil?  && current_fb_post.updated_time <= fb_post_graph_object["updated_time"]
		    	save_fb_comments current_fb_post, fb_post_graph_object
		    	current_fb_post.update_attributes(updated_time: fb_post_graph_object["updated_time"])
		    else
		    	logger.debug ""
			end
		end
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

            fb_comment = fb_post.fb_comments.new(this_comment)
            @comment_count +=1  

            if fb_comment.save
              @saved_comments << fb_comment
            else
              @rejected_comments += 1
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

					fb_nested_comment = fb_post.fb_comments.new(nested_comment)

					@comment_count +=1

					if fb_nested_comment.save
						 @saved_comments << fb_nested_comment
					else
						@rejected_comments += 1
					end
				end
            end

        end
	end

	#-------------------------------------------------------------------------

	private

		def fb_graph
			@fb_graph ||= Koala::Facebook::API.new(fb_app_access_token)
		end

		def fb_app_access_token
			@fb_app_access_token ||= AppSetting.last.fb_app_access_token
		end

		def set_page_defaults
			self.scrape_frequency  = SCRAPE_FREQUENCY_DEFAULT  if scrape_frequency == nil
			self.continous_scrape  = CONTINUOUS_SCRAPE_DEFAULT if continous_scrape == nil
			self.override_session_settings = OVERRIDE_SESSION_DEFAULT if override_session_settings == nil
		end

		def set_next_scrape_date
			self.scrape_frequency  = SCRAPE_FREQUENCY_DEFAULT if scrape_frequency == nil
			self.next_scrape_date  = Time.now + scrape_frequency
		end

		def page_setup
			clean_page_url 
			set_page_type 
			get_fb_page_id
			set_page_defaults
			logger.debug "page setup complete"
			logger.debug "self => #{self.inspect}"
		end

		def get_fb_page_id
			logger.debug "inside get_fb_page_id"

			if page_type == "page" 

				begin
					@page_profile    = fb_graph.get_object(page_url)
				rescue Exception => e 				# swap Koala::Facebook::APIError
					self.errors.add(:page_url, "#{e.message}")
				end

				if @page_profile.nil? 
					self.errors.add(:page_url, "Invalid URL!!" )
				else
					self.fb_page_id = @page_profile["id"].to_s
				end

			elsif self.page_type == "group"
				crawl_and_get_id page_url
			end

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
		end

		def set_page_type
			self.page_type =  page_url =~ /(groups)\// ? "group" : "page"
		end
end
