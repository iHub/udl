class Answer < ActiveRecord::Base

	#associations
	belongs_to :question
	has_many :annotations, dependent: :destroy	
	
	validates :answer, presence: true
end
