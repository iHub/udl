class ScrapeSession < ActiveRecord::Base

	#associations
	belongs_to :user
	has_many :scrape_pages, dependent: :destroy
	has_many :fb_posts, 	:through => :scrape_pages
	has_many :fb_comments, 	:through => :fb_posts

	has_many :questions, 	dependent: :destroy
	has_many :annotators, 	dependent: :destroy
	has_many :annotations, 	dependent: :destroy

	default_scope -> { order('created_at DESC') }
	# validates :user_id, presence: true
	validates :name, 	presence: true

	def user_name
		session_owner = User.find(self.user_id)
		"#{session_owner.firstname} #{session_owner.lastname}"
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

	# def created_on_friendly
	# 	created_at = self.created_at
	# 	civil_from_format.created_at
	# end
end
