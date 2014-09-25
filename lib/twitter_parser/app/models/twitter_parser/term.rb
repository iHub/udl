module TwitterParser
  class Term < ActiveRecord::Base
  	validates :title, presence: true, uniqueness: true

  	after_commit :reload_terms, on: :create

  private

  	def reload_terms
  		TweetWorker.perform_async(self.id, nil, "fetch")
  	end

  end
end