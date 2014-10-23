class DisqusForum < ActiveRecord::Base
  belongs_to :user
  belongs_to :scrape_session
  has_many :disqus_forum_comments, dependent: :destroy

  # validates :user, :scrape_session, presence: true
  validates :forum_name, presence: true, uniqueness: true

  after_create :fetch_disqus_comments

  def to_s
  	forum_name ? "#{forum_name}" : "#{self.object_id}"
  end

private
	
	def fetch_disqus_comments
		DisqusWorker.perform_async(self.id)
	end

end