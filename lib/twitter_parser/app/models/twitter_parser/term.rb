module TwitterParser
  class Term < ActiveRecord::Base
    include PgSearch

  	belongs_to :scrape_session	
  	validates :title, presence: true, uniqueness: true
  	after_commit :reload_terms, on: :create
    before_save :downcase_twitter_term

  private

  	def reload_terms
  		TweetWorker.perform_async
  	end

    def downcase_twitter_term
      self[:title] = title.downcase
    end

  end
end