module Tagger
  class Question < ActiveRecord::Base
    belongs_to :scrape_session
    has_many :answers

    validates_presence_of :scrape_session
    validates_uniqueness_of :content
    
    attr_accessor :tagger_ids, :user_ids, :disqus_num, :twitter_num
    accepts_nested_attributes_for :answers, allow_destroy: true

    def to_s
    	content
    end

    class << self
    	def assign_records_to_user(params)        
    		AssignQuestionWorker.perform_async(params)
    	end

    	def question_forum(params)
    		find(params[:question_id])
    	end
    end
  end
end
