class Question < ActiveRecord::Base

	#associations
	belongs_to :scrape_session, counter_cache: true  
	has_many :answers, dependent: :destroy

	validates :question, presence: true	
end
