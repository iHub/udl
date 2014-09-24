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

#########TwitterParser && Tagger#############################
	has_many :questions, :class_name => "Tagger::Question"
	has_many :terms, :class_name => "TwitterParser::Term"

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
		has_settings ||= AppSetting.last
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
		file_pages_url_strip = []
		
		logger.debug "params file => #{file.inspect}"
		import_pages = SmarterCSV.process(file.tempfile)
		logger.debug "import_pages => #{import_pages.inspect}"
		import_pages.each do |page|
			# logger.debug "key, value => #{key.inspect} , #{value.inspect}"
			file_pages_url_strip << page[:page_url].gsub(/.*(facebook.com)[\/]/, '') 
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

		session_controlled_scrape_pages = ScrapePage.where(scrape_session_id: ScrapeSession.absolute.continuous.select(:id))
		session_controlled_page_delegated_scrape_pages  = ScrapePage.where(scrape_session_id: ScrapeSession.overridden.continuous.select(:id)).no_override
		page_controlled_scrape_pages    = ScrapePage.where(scrape_session_id: ScrapeSession.overridden.select(:id)).has_override.continuous

		session_controlled_scrape_pages.each 			    { |this_page| collect_page_comments this_page, "session"}
		session_controlled_page_delegated_scrape_pages.each { |this_page| collect_page_comments this_page, "session"}
		page_controlled_scrape_pages.each   				{ |this_page| collect_page_comments this_page, "page" if this_page.next_scrape_date < Time.now }

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
			current_page.get_fb_posts next_date, end_date
			current_page.get_fb_comments
		end
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