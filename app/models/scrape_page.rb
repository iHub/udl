class ScrapePage < ActiveRecord::Base
	
	attr_accessor :scrape_frequency_select
	#associations
	belongs_to  :scrape_session	
	has_many    :fb_posts, 		dependent: :destroy
	has_many	:fb_comments, :through => :fb_posts

	scope 	:continous, -> { where(continous_scrape: true) }

	validates :page_url, presence: true
	validates :fb_page_id, presence: true

	validates :scrape_frequency, presence: true, if: :continous_scrape?
	validates :scrape_frequency,  :numericality => {:only_integer => true}


	def epoch_time(standard_date_time)
		standard_date_time.to_time.utc.to_i
	end

	def total_posts
		self.fb_posts.count
	end

	def total_comments
		total_comments = 0
		self.fb_posts.find_each do |fb_post|
			total_comments += fb_post.fb_comments.count
		end
		total_comments
	end

	def collect_comments
		logger.debug ">>>>>>>>>>>>>>>>> collect_comments running >>>>>>>>>>>>>>>>>"

		scraping_pages = ScrapePage.continous
		logger.debug "Number of pages that have continous collection: #{scraping_pages.count}"

		if scraping_pages.count > 0
			scraping_pages.each do |current_scrape_page|
				if epoch_time current_scrape_page.next_scrape_date  < epoch_time Time.now
					logger.debug "next_scrape_date < Time.now ||| #{current_scrape_page.next_scrape_date} vs #{Time.now}"
					logger.debug "get_new_fb_posts called"

					get_new_fb_posts current_scrape_page

					logger.debug "calling get_new_fb_comments"

					get_new_fb_comments current_scrape_page.id

					# set date for next scrape & save to db
					next_scrape_date = Time.now + current_scrape_page.scrape_frequency
					current_scrape_page.update(next_scrape_date: next_scrape_date)
				end
			end
			logger.debug "*********************** All pages processed ***********************"
		else
			logger.debug "No pages with continous scraping set up"
		end
	end
	# handle_asynchronously :collect_comments, priority: 20, queue: "continuous_scrape"

	def get_new_fb_posts(scrape_page)		
		logger.debug "SCRAPER : get_fb_posts >>>"
		scrape_page.next_scrape_date = Time.now - 1.day if scrape_page.next_scrape_date?
		get_fb_posts scrape_page, epoch_time(scrape_page.next_scrape_date) , epoch_time(Time.now)
	end

	def get_new_fb_comments(scrape_page_id)
		logger.debug "SCRAPER : get_new_fb_comments >>>"
		get_fb_comments scrape_page_id
	end

	def valid_page_url(fb_url, scrape_session_id)
		
		scrape_session = ScrapeSession.find(scrape_session_id)
		scrape_page = scrape_session.scrape_pages.find_by_page_url(fb_url)

		return "duplicate" if scrape_page

		begin
			graph 		  = Koala::Facebook::API.new(fb_app_access_token)
			page_profile  = graph.get_object(fb_url)
			self.fb_page_id = page_profile["id"]
			logger.debug "inside valid_page_url method | fb_page_id => #{page_profile["id"]}"
			return "valid"
		rescue Exception => e 				# swap Koala::Facebook::APIError
			# flash.now[:danger] = e
			return e.message
		end

	end

	def valid_init_scrape_date(start_date, end_date)

		if start_date.nil? && end_date.nil?
			return "false"
		elsif !start_date.nil? && !end_date.nil?
			return "true"
		elsif ( !start_date.nil? && end_date.nil? ) || ( start_date.nil? && !end_date.nil?)
			return "Please enter both dates for the Initial collection"
		end
	end

	def init_scrape_start

		start_date   = self.initial_scrape_start.to_time.utc.to_i         # convert date to unix epoch time
		end_date     = self.initial_scrape_end.to_time.utc.to_i

		@last_result_created_time = end_date
		logger.debug ">>>>>>>>>>> Running Init Scrape Start (via Controller) <<<<<<<<<<<<"

		get_fb_posts self, start_date, end_date
		logger.debug "get_fb_posts complete =>> get_fb_comments"

		get_fb_comments self.id
		logger.debug "get_fb_comments complete"
	end
	handle_asynchronously :init_scrape_start, priority: 20, queue: "initscrape"


	def get_fb_comments(scrape_page_id)
		logger.debug "<<<<<<<<<<<< Running get_fb_comments  >>>>>>>>>>>"

		this_page = ScrapePage.find(scrape_page_id)
		all_posts = this_page.fb_posts

		logger.debug "all_posts.count => #{all_posts.count}"
		return false if all_posts.count == 0

		@comment_list = []
		@comment_count = 0

		@comment_count  = 0 
		@saved_comments 	 = 0

		all_posts.each do |current_fb_post|

			logger.debug "going through each post from all_post collection object"

			logger.debug "perform graph search on current_fb_post from all_posts"

			fb_post_graph_object = fb_graph.get_object(current_fb_post.fb_post_id, :fields => "comments.fields(comments.fields(from,message,created_time),message,from,created_time).limit(1000)")
			
			logger.debug "graph complete on current_fb_post"
			logger.debug "fb_post_graph_object => #{fb_post_graph_object.inspe}"
			logger.debug "pass graph query result to save_fb_comments"

			if !fb_post_graph_object["comments"].nil?
		    	save_fb_comments current_fb_post, fb_post_graph_object
		    else
		    	logger.debug "fb_post_graph_object[\"comments\"].nil? => #{fb_post_graph_object["comments"].nil?} "
			end
		end
	end

	def save_fb_comments(fb_post, fb_post_graph_object)

		if !fb_post_graph_object["comments"].nil?
	        fb_post_graph_object["comments"]["data"].each do |comment|
	            this_comment = {}
	            this_comment[:comment_id]      = comment["id"]
	            this_comment[:message]         = comment["message"]
	            this_comment[:from_user_id]    = comment["from"]["id"]
	            this_comment[:from_user_name]  = comment["from"]["name"]
	            this_comment[:created_time]    = comment["created_time"]
	            this_comment[:fb_post_id]      = fb_post.id
	            this_comment[:parent_id]       =  "0"

	            # @get_next_page = true

	            fb_comment = fb_post.fb_comments.build(this_comment)

	            @comment_list << this_comment

	            @comment_count +=1  

	            if fb_comment.save
	              @saved_comments +=1
	              logger.debug "SAVED. @saved_comments = #{@saved_comments}"
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

						@comment_list << nested_comment

						fb_comment = fb_post.fb_comments.build(nested_comment)

						@comment_count +=1

						if fb_comment.save
							@saved_comments +=1
							logger.debug "SAVED -- Nested comment. @saved_comments = #{@saved_comments}"
						else
							logger.debug "<><><><><><> Nested Comment not SAVED. Possible Duplicate <><><><><><>"
						end
					end
	            end

	        end
	        logger.debug "fb_post_graph_object processing complete"
	    end
		
	end

	def get_fb_posts(scrape_page, start_date, end_date)

		logger.debug "============ Running get_fb_posts ==============="

		query_limit  = 500
		posts_fql_query = "SELECT post_id, message, created_time FROM stream WHERE source_id = '#{scrape_page.fb_page_id}' AND message != '' AND created_time > #{start_date} AND created_time < #{end_date} LIMIT #{query_limit}"
		logger.debug "posts_fql_query => #{posts_fql_query}"

		fb_posts = fb_graph.fql_query(posts_fql_query)

		if !fb_posts.empty?
		    
		    logger.debug "----- Before Save ----------"
		    logger.debug "fb_posts.inspect => #{fb_posts.inspect}"

		    save_fb_posts scrape_page, fb_posts

		    logger.debug "@last_result_created_time => #{@last_result_created_time}"
		    logger.debug "start_date => #{start_date}"
		    logger.debug "end_date => #{end_date}"

		    if @last_result_created_time > start_date
		        logger.debug "@last_result_created_time < start_date => true"
		        logger.debug "@last_result_created_time => #{@last_result_created_time} vs start_date => #{start_date}"
		        get_fb_posts scrape_page, start_date, @last_result_created_time
		    end

		elsif fb_posts.empty?
		    logger.debug "###################### fb_posts is Empty!"
		end

	end

	def save_fb_posts(scrape_page, fb_posts)
		logger.debug "_________________ save_fb_posts ____________________"
		logger.debug "fb_posts.nil? => #{fb_posts.nil?}"


		fb_posts.each do |fb_post|
		    this_post = {}
		    this_post[:fb_post_id] 	    = fb_post["post_id"]
		    this_post[:created_time] 	= Time.at(fb_post["created_time"]).utc
		    this_post[:message] 		= fb_post["message"]
		    this_post[:fb_page_id] 		= scrape_page.fb_page_id
		    this_post[:scrape_page_id]  = scrape_page.id
		    
		    current_post = FbPost.new(this_post)

		    this_post_created_at = (current_post.created_time).to_time.utc.to_i

		    @last_result_created_time = this_post_created_at

		    logger.debug "@last_result_created_time => #{@last_result_created_time}"

		    # if @last_result_created_time <  this_post_created_at
		    #     @last_result_created_time = this_post_created_at
		    # end

		    if current_post.save
		        logger.debug "!!!!!!!!!!!!!!!!!! Record Saved !!!!!!!!!!!!!!!!!!"
		    else
		    	logger.debug "--------------- Record NOT Saved | possible duplicate -----------------"
		    end
		end

		logger.debug "**************** save_fb_posts complete ****************"

	end

	private

		def fb_graph
			fb_graph ||= Koala::Facebook::API.new(fb_app_access_token)
		end

		def fb_app_access_token
			fb_app_access_token ||= AppSetting.last.fb_app_access_token
		end
end
