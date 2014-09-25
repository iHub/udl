module Tagger
  class Answer < ActiveRecord::Base
    belongs_to :question

    has_many :tweet_answers
		has_many :tweets, :through => :tweet_answers, class_name: "TwitterParser::Tweet"
  end
end
