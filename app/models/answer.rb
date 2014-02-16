class Answer < ActiveRecord::Base

	#associations
	belongs_to :question, counter_cache: true    
	has_many :annotations, dependent: :destroy	
	
	validates :answer, presence: true
end
