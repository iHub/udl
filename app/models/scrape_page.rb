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

	# def scrape_frequency=() 
	# 	logger.debug "scrape_frequency_select => #{scrape_frequency_select}"
	# 	frequency = case self.scrape_frequency_select
	# 		when "10 Minutes"	then 10.minutes.to_i
	# 		when "30 Minutes"	then 30.minutes.to_i
	# 		when "1 Hour"		then 1.hour.to_i
	# 		when "3 Hours"		then 3.hours.to_i
	# 		when "6 Hours"		then 6.hours.to_i
	# 		when "12 Hours"		then 12.hours.to_i
	# 		when "Daily"		then 1.day.to_i
	# 		when "Every 3 Days"	then 3.days.to_i
	# 		when "Weekly"		then 1.week.to_i
	# 		else  10.minutes.to_i
	# 	end
	# 	 write_attribute(:scrape_frequency, frequency)
	# end

	# def scrape_frequency_select
	# 	@scrape_frequency_select
	# end

	# def scrape_frequency_select=(value)
	# 	@scrape_frequency_select = value
	# end

	# def scrape_fb_page (page_url, start_scrape_date, end_scrape_date)
	# 	logger.debug "Delayed JOB :: scrape_fb_page called"
	# 	@comment_list = []
	# 	@get_next_page = false
	# 	@request_page_count = 0

	# 	begin
	# 		graph = Koala::Facebook::API.new(fb_app_access_token)
	# 	rescue Koala::Facebook::APIError => e
	# 		flash.now[:danger] = e
	# 		return	false
	# 	end

	# 	logger.debug "page_url #{page_url}"
	# 	@page_feed = graph.get_connections(page_url, "feed", :fields => "comments")

	# 	get_fb_comments @page_feed, start_scrape_date, end_scrape_date

	# 	until @get_next_page == false
	# 		logger.debug  "@get_next_page block => #{@get_next_page}"
	# 		@request_page_count +=1
	# 		next_page_feed = @page_feed.next_page
	# 		get_fb_comments next_page_feed, start_scrape_date, end_scrape_date
	# 	end
	# 	logger.debug "Comment List => \n #{@comment_list}"
	# 	@comment_list
	# end

	# def get_fb_comments(current_page_feed, start_scrape_date, end_scrape_date)
	# 	logger.debug "running get_fb_comments method"

	# 	current_page_feed.each do |message_object|
	# 		if !message_object["comments"].nil?
	# 			message_object["comments"]["data"].each do |comment|
	# 				@init_scrape_post_count +=1 			
					
	# 				comment_created_at = comment["created_time"].to_datetime

	# 				# if scrape_frequency.nil? 
	# 				# 	end_scrape_date = 10.minutes.ago  # hard code limit for scrape page end date
	# 				# else
	# 				# 	end_scrape_date = scrape_frequency.minutes.ago
	# 				# end

	# 				logger.debug "comment_created_at #{comment_created_at.strftime("%I:%M %p, %b %e %Y")}"
	# 				# logger.debug "end_scrape_date #{end_scrape_date.strftime("%I:%M %p, %b %e %Y")}"
	# 				# logger.debug "date compare: (comment_created_at > end_scrape_date) => #{(comment_created_at > end_scrape_date)}"
	# 				# logger.debug "@scrape_page.id => #{@scrape_page.id}"

	# 				if (comment_created_at > end_scrape_date)
	# 					# logger.debug "in the block if(comment_created_at < end_scrape_date)"
	# 					this_comment = {}
	# 					this_comment[:comment_id] 	 	 = comment["id"] 
	# 					this_comment[:from_user_id]  = comment["from"]["id"]
	# 					this_comment[:from_user_name] 	 = comment["from"]["name"]
	# 					this_comment[:message]  = comment["message"]
	# 					this_comment[:created_time]	 = comment_created_at
	# 					this_comment[:scrape_page_id]	 = self.id

	# 					@get_next_page = true

	# 					@facebook_post = @scrape_page.facebook_posts.build(this_comment)
	# 					@comment_list << this_comment

	# 					if @facebook_post.save
	# 						@init_scrape_post_count +=1
	# 						logger.debug "SAVED. @init_scrape_post_count = #{@init_scrape_post_count}"
	# 					end

	# 				else 
	# 					logger.debug "!(comment_created_at < end_scrape_date) so setting get_next_page to false"
	# 					@get_next_page = false
	# 				end
	# 			end # message_object each
	# 		elsif message_object["comments"].nil?
	# 			logger.debug "I'm nil bitch!"
	# 		end # if not nil
	# 	end # current page feed main block
	# 	@comment_list
	# end

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

	# def self.init_scrape_start(id)
	# 	init_scrape_start(id)
	# end

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

		    # current_page["comments"]["data"].each do |comment|

		    #     this_comment = {}
		    #     this_comment[:comment_id]      = comment["id"]
		    #     this_comment[:message]         = comment["message"]
		    #     this_comment[:from_user_id]    = comment["from"]["id"]
		    #     this_comment[:from_user_name]  = comment["from"]["name"]
		    #     this_comment[:created_time]    = comment["created_time"]
		    #     this_comment[:fb_post_id]      = current_fb_post.id
		    #     this_comment[:parent_id]       =  "0"

		    #     @get_next_page = true

		    #     fb_comment = fb_post.fb_comments.build(this_comment)

		    #     @comment_list << this_comment

		    #     if fb_comment.save
		    #       @comment_count +=1
		    #       logger.debug "SAVED. @comment_count = #{@comment_count}"
		    #     end

		    #     # grab nested comments
		    #     if !comment["comments"].nil?
		    #         comment["comments"]["data"].each do |comment_reply|
		    #             nested_comment = {}
		    #             nested_comment[:comment_id]      = comment_reply["id"]
		    #             nested_comment[:message]         = comment_reply["message"]
		    #             nested_comment[:from_user_id]    = comment_reply["from"]["id"]
		    #             nested_comment[:from_user_name]  = comment_reply["from"]["name"]
		    #             nested_comment[:created_time]    = comment_reply["created_time"]
		    #             nested_comment[:fb_post_id]      = current_fb_post.id
		    #             nested_comment[:parent_id]       = this_comment[:comment_id]

		    #             @comment_list << nested_comment

		    #             fb_comment = fb_post.fb_comments.build(nested_comment)

		    #             if fb_comment.save
		    #               @comment_count +=1
		    #               logger.debug "SAVED -- Nested comment. @comment_count = #{@comment_count}"
		    #             end
		    #         end
		    #     end

		    # end
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
