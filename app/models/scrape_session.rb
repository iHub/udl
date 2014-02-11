class ScrapeSession < ActiveRecord::Base

	attr_accessor :scrape_frequency_select

	# associations
	belongs_to :user
	has_many :scrape_pages, dependent: :destroy

	# data from outside
	has_many :fb_posts, 	:through => :scrape_pages
	has_many :fb_comments, 	:through => :fb_posts

	has_many :questions, 	dependent: :destroy
	has_many :annotators, 	dependent: :destroy
	has_many :annotations, 	dependent: :destroy

	# log associations
	has_many :question_logs,	dependent: :destroy
	has_many :answer_logs, 		dependent: :destroy
	has_many :scrape_page_logs, dependent: :destroy

	# has_many :init_scrape_logs, 	dependent: :destroy
	has_many :regular_scrape_logs,  dependent: :destroy

	###############################################

	default_scope -> { order('created_at DESC') }
	scope 	:continuous, -> { where(session_continuous_scrape: true) }	# active collection
	scope 	:dormant,    -> { where(session_continuous_scrape: false) }	# active collection
	scope 	:absolute, 	 -> { where(allow_page_override: false) }
	scope 	:overridden, -> { where(allow_page_override: true) }

	# validates :user_id, presence: true
	validates :name, 	presence: true

	def user_name
		session_owner = User.find(self.user_id)
		"#{session_owner.firstname.capitalize} #{session_owner.lastname.capitalize}"
	end

	def total_pages
		self.scrape_pages.count
	end

	def total_posts
		self.fb_posts.count
	end

	def total_comments
		self.fb_comments.count
	end

#-------------------------------------
# refactor to module
#-------------------------------------

	def has_app_access_token?
		has_settings = AppSetting.last
		if !has_settings.nil?
			return true if !has_settings.fb_app_access_token.nil? 		
		end
	end

	def epoch_time(standard_date_time)
		standard_date_time.to_time.utc.to_i
	end

#-------------------------------------
# Import methods
#-------------------------------------

	def self.import(file)
		file_pages = []
		
		logger.debug "params file => #{file.inspect}"

		import_pages = SmarterCSV.process(file.original_filename)

		logger.debug "import_pages => #{import_pages.inspect}"

		# spreadsheet = open_spreadsheet(file)
		# logger.debug "spreadsheet => #{spreadsheet.inspect}"
		# header = spreadsheet.row(1)
		# (2..spreadsheet.last_row).each do |i|
		# 	file_pages << spreadsheet.cell(1,i)
		# end
		# logger.debug "file_pages => #{file_pages.inspect}"
	end

	def self.open_spreadsheet(file)
		case File.extname(file.original_filename)
			when ".csv"  then Roo::Csv.new(file.path)
			when ".xls"  then Roo::Excel.new(file.path)
			when ".xlsx" then Roo::Excelx.new(file.path)
			else raise "Unknown file type: #{file.original_filename}"
		end
	end


#-------------------------------------
# Scraper methods
#-------------------------------------

	def parse_all_sessions
		# scenario 1: session controls scraping
		# session doesnt allow overrides && is continous 
		master_sessions_active = ScrapeSession.absolute.continuous
		master_sessions_active.each do |this_session|

			logger.debug "This session => #{this_session.inspect}"
			if this_session.session_next_scrape_date < Time.now

				this_session.scrape_pages.each do |this_page|

					logger.debug "This page => #{this_page.inspect}"
					collect_page_comments this_page, "session"
				end
			end
		end

		# scenario 2: session passes control of scraping but page doesn't want control
		# session allows overrides && is continous 
		passive_sessions_active = ScrapeSession.overridden.continuous
		passive_sessions_active.each do |this_session|
			if this_session.session_next_scrape_date < Time.now
				this_session.scrape_pages.no_override.each do |this_page|
					collect_page_comments this_page, "session"
				end
			end
		end

		# scenario 3: session passes control of scraping && page wants control
		# session allows overrides && is continous 
		passive_sessions_page_active = ScrapeSession.overridden
		passive_sessions_page_active.each do |this_session|
			this_session.scrape_pages.has_override.continuous.each do |this_page|
				collect_page_comments this_page, "page" if this_page.next_scrape_date < Time.now
			end
		end
	end

	def collect_page_comments(current_page, setting_source)
		if setting_source == "session"
			frequency = current_page.scrape_session.session_scrape_frequency
			next_date = epoch_time current_page.scrape_session.session_next_scrape_date
		elsif setting_source == "page"
			frequency = current_page.scrape_frequency
			next_date = epoch_time current_page.next_scrape_date
		end

		end_date = epoch_time Time.now 


		if next_date < epoch_time(Time.now)
			# logger.debug "next_scrape_date < Time.now ||| #{current_scrape_page.next_scrape_date} vs #{Time.now}"
			# logger.debug "get_new_fb_posts called"

			# @saved_posts_count      = 0
			# @saved_comments_count   = 0
			# get_new_fb_posts current_page

			# logger.debug "calling get_new_fb_comments"
			# get_new_fb_comments current_scrape_page.id

			get_fb_posts current_page, next_date, end_date

			get_fb_comments current_page.id

			# current_page.session_control_get_posts 

			# set date for next scrape & save to db
			# next_date = Time.now + frequency
			# current_page.update(next_scrape_date: next_date)
			# current_page.scrape_session.update(session_next_scrape_date: next_date)
		end
	end


#---------------------------------------------------


	# extract to class and reuse in scrape page class
	# handle fb posts > get and save

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

	#---------------------------------------------------

	# handle fb comments > get and save

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
			logger.debug "fb_post_graph_object => #{fb_post_graph_object.inspect}"
			logger.debug "pass graph query result to save_fb_comments"

			if !fb_post_graph_object["comments"].nil?
		    	save_fb_comments current_fb_post, fb_post_graph_object
		    else
		    	logger.debug "fb_post_graph_object[\"comments\"].nil? => #{fb_post_graph_object["comments"].nil?} "
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

	#---------------------------------------------------


	private

		def fb_graph
			fb_graph ||= Koala::Facebook::API.new(fb_app_access_token)
		end

		def fb_app_access_token
			if has_app_access_token?
				fb_app_access_token ||= AppSetting.last.fb_app_access_token
			end 
		end
end