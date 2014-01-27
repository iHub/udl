class FacebookPost < ActiveRecord::Base

	# associations
	belongs_to :scrape_page

	# validations
	validates :comment_id, presence: true, uniqueness: true

	def scrape_page_name
		parent_scrape_page = ScrapePage.find(self.scrape_page_id)
		parent_scrape_page.page_url
	end
end
