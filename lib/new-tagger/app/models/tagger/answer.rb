module Tagger
  class Answer < ActiveRecord::Base
    belongs_to :question

    has_many :tweet_answers
		has_many :tweets, :through => :tweet_answers, class_name: "TwitterParser::Tweet"
  
		has_many :disqus_answers
		has_many :disqus_comments, through: :disqus_answers

		# validates_presence_of :content
  end
end
