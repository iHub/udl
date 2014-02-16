class ScrapeSession < ActiveRecord::Base

	attr_accessor :scrape_frequency_select

	# associations
	belongs_to :user, counter_cache: true	
	has_many :scrape_pages, dependent: :destroy

	# data from outside
	has_many :fb_posts, 	:through => :scrape_pages
	has_many :fb_comments, 	:through => :fb_posts

	has_many :questions, 	dependent: :destroy
	has_many :answers, 		through:   :questions
	has_many :annotators, 	dependent: :destroy
	has_many :annotations, 	dependent: :destroy

	# log associations
	has_many :question_logs,	dependent: :destroy
	has_many :answer_logs, 		dependent: :destroy
	has_many :scrape_page_logs, dependent: :destroy

	# has_many :init_scrape_logs, 	dependent: :destroy
	has_many :regular_scrape_logs,  dependent: :destroy


	default_scope -> { order('created_at DESC') }
	scope 	:continuous, -> { where(session_continuous_scrape: true) }	# active collection
	scope 	:dormant,    -> { where(session_continuous_scrape: false) }	# active collection
	scope 	:absolute, 	 -> { where(allow_page_override: false) }
	scope 	:overridden, -> { where(allow_page_override: true) }

	# validates :user_id, presence: true
	validates :name, 	presence: true

	SCRAPE_FREQUENCY_DEFAULT    = 600
	CONTINUOUS_SCRAPE_DEFAULT   = false
	ALLOW_PAGE_OVERRIDE_DEFAULT = false

	before_create :set_defaults
	before_save   :set_next_scrape_date

	after_create  :log_event_create
	after_update  :log_event_edit
	after_destroy :log_event_delete

	def user_name
		session_owner = User.find(self.user_id)
		"#{session_owner.firstname.capitalize} #{session_owner.lastname.capitalize}"
	end

	def total_pages
		self.scrape_pages.size
	end

	def total_posts
		self.fb_posts.size
	end

	def total_comments
		self.fb_comments.size
	end

#-------------------------------------
# refactor to module
#-------------------------------------

	def epoch_time(standard_date_time)
		standard_date_time.to_time.utc.to_i
	end

#-------------------------------------
# Import methods
#-------------------------------------

	def csv_import(file)
		file_pages_url_strip = []
		
		logger.debug "params file => #{file.inspect}"
		import_pages = SmarterCSV.process(file.tempfile)
		logger.debug "import_pages => #{import_pages.inspect}"
		import_pages.each do |page|
			# logger.debug "key, value => #{key.inspect} , #{value.inspect}"
			# file_pages_url_strip << page[:page_url].gsub(/.*(facebook.com)[\/]/, '') 
			import_page = ScrapePage.new
			logger.debug "page[:page_url] => #{page[:page_url]}"
			import_page.page_url 		  = page[:page_url]
			import_page.scrape_session_id = self.id
			logger.debug "import_page.page_url => #{import_page.page_url}"
			if import_page.save
				logger.debug "Valid url -- added to db"
			end
		end

		logger.debug "file_pages_url_strip => #{file_pages_url_strip.inspect}"

		# spreadsheet = open_spreadsheet(file)
		# logger.debug "spreadsheet => #{spreadsheet.inspect}"
		# header = spreadsheet.row(1)
		# (2..spreadsheet.last_row).each do |i|
		# 	file_pages << spreadsheet.cell(1,i)
		# end
		# logger.debug "file_pages => #{file_pages.inspect}"
	end

	def self.open_spreadsheet(file)
		case File.extname(file.tempfile)
			when ".csv"  then Roo::Csv.new(file.path)
			when ".xls"  then Roo::Excel.new(file.path)
			when ".xlsx" then Roo::Excelx.new(file.path)
			else raise "Unknown file type: #{file.original_filename}"
		end
	end

#-------------------------------------
# Session Scraper methods
#-------------------------------------

	def parse_all_sessions
		logger.debug "Starting parse_all_sessions"
		session_controlled_scrape_pages =  ScrapePage.where(scrape_session_id: ScrapeSession.absolute.continuous.select(:id))
		session_controlled_scrape_pages += ScrapePage.where(scrape_session_id: ScrapeSession.overridden.continuous.select(:id)).no_override
		page_controlled_scrape_pages    =  ScrapePage.where(scrape_session_id: ScrapeSession.overridden.select(:id)).has_override.continuous

		end_date = epoch_time Time.now 

		session_controlled_scrape_pages.each 	do |this_page|
			next_date = epoch_time current_page.scrape_session.session_next_scrape_date
			this_page.retro_scrape next_date, end_date if this_page.scrape_session.session_next_scrape_date < Time.now
			next_scrape_date = Time.now + this_page.scrape_session.session_scrape_frequency
			this_page.scrape_session.update_attributes(session_next_scrape_date: next_scrape_date)
		end		    

		page_controlled_scrape_pages.each do |this_page|
			next_date = epoch_time current_page.scrape_session.session_next_scrape_date
			this_page.retro_scrape next_date, end_date if this_page.next_scrape_date < Time.now
			next_scrape_date = Time.now + this_page.scrape_frequency
			this_page.update_attributes(next_scrape_date: next_scrape_date)
		end			

	end

	# def collect_page_comments(current_page, setting_source)
	# 	if setting_source == "session"
	# 		logger.debug "Collecting via session settings"
	# 		frequency = current_page.scrape_session.session_scrape_frequency
			
	# 	elsif setting_source == "page"
	# 		logger.debug "Collecting via scrape page settings"
	# 		frequency = current_page.scrape_frequency
	# 		next_date = epoch_time current_page.next_scrape_date
	# 	end

	# 	end_date = epoch_time Time.now 

	# 	if next_date < epoch_time(Time.now)
	# 		current_page.retro_scrape next_date, end_date
	# 		# current_page.get_fb_posts next_date, end_date
	# 		# current_page.get_fb_comments
	# 	end
	# end

	#---------------------------------------------------


	private

		def set_defaults
			self.session_scrape_frequency  = SCRAPE_FREQUENCY_DEFAULT if session_scrape_frequency == nil
			self.session_continuous_scrape = CONTINUOUS_SCRAPE_DEFAULT if session_continuous_scrape == nil
			self.allow_page_override       = ALLOW_PAGE_OVERRIDE_DEFAULT if allow_page_override      == nil
			self.session_next_scrape_date  = Time.now + session_scrape_frequency
		end

		def set_next_scrape_date
			self.session_scrape_frequency  = SCRAPE_FREQUENCY_DEFAULT if session_scrape_frequency == nil		
			self.session_next_scrape_date  = Time.now + session_scrape_frequency
		end

		def log_event_create
			log_scrape_session_event "create"
		end

		def log_event_edit
			log_scrape_session_event "edit"
		end

		def log_event_delete
			logger.debug "current_user => #{current_user.inspect}"
			log_scrape_session_event "delete"
		end

		def log_scrape_session_event(event)
			event_params = {}
			event_params[:scrape_session_id] 		= id
			event_params[:scrape_session_name] 	    = name
			event_params[:event_time]  				= Time.now
			event_params[:user_id]     				= current_user.id
			event_params[:username]    				= current_user.username
			event_params[:event_type]  				= event

			event_params[:session_scrape_frequency]     = session_scrape_frequency
			event_params[:session_next_scrape_date]		= session_next_scrape_date
			event_params[:session_continuous_scrape]	= session_continuous_scrape
			event_params[:allow_page_override]			= allow_page_override
			event_params[:scrape_page_count]			= total_pages
			event_params[:fb_posts_count]				= total_posts
			event_params[:fb_comments_count]			= total_comments

			log_event = ScrapeSessionLog.new(event_params)

			if log_event.save
				logger.debug "scrape_session Log : #{event}"
			end 

	    end
end