class Question < ActiveRecord::Base

	#associations
	belongs_to :scrape_session
	has_many :answers, dependent: :destroy

	validates :question, presence: true	
end
