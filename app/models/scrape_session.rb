class ScrapeSession < ActiveRecord::Base

	default_scope -> { order('created_at DESC') }
	scope 	:continuous, -> { where(session_continuous_scrape: true) }	# active collection
	scope 	:dormant,    -> { where(session_continuous_scrape: false) }	# active collection
	scope 	:absolute, 	 -> { where(allow_page_override: false) }
	scope 	:overridden, -> { where(allow_page_override: true) }


	SCRAPE_FREQUENCY_DEFAULT    = 600
	CONTINUOUS_SCRAPE_DEFAULT   = false
	ALLOW_PAGE_OVERRIDE_DEFAULT = false


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


	validates :name, 	presence: true


	before_create :set_defaults
	before_save   :set_next_scrape_date


	def user_name
		session_owner = User.find(self.user_id)
		"#{session_owner.firstname.capitalize} #{session_owner.lastname.capitalize}"
	end

	def total_pages
		self.scrape_pages_count
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
		
		return false if file.nil?

		file_pages_url_strip = []

		begin
			import_pages = SmarterCSV.process(file.tempfile)
		rescue Exception => e
			self.errors.add(:file, "#{e.message}")
			return false
		end
		
		import_pages.each do |page|
			
			import_page = ScrapePage.new
			import_page.page_url 		  = page[:page_url]
			import_page.scrape_session_id = self.id
			if import_page.save
				#--- log this
			end
		end

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
		session_controlled_scrape_pages =  ScrapePage.where(scrape_session_id: ScrapeSession.absolute.continuous.select(:id))
		session_controlled_scrape_pages += ScrapePage.where(scrape_session_id: ScrapeSession.overridden.continuous.select(:id)).no_override
		page_controlled_scrape_pages    =  ScrapePage.where(scrape_session_id: ScrapeSession.overridden.select(:id)).has_override.continuous

		end_date = epoch_time Time.now 

		session_controlled_scrape_pages.each 	do |this_page|
			next_date = epoch_time this_page.scrape_session.session_next_scrape_date
			this_page.regular_scrape next_date, end_date if next_date < end_date
		end		    

		page_controlled_scrape_pages.each do |this_page|
			next_date = epoch_time this_page.next_scrape_date
			this_page.regular_scrape next_date, end_date if next_date < end_date
		end			

	end

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

end