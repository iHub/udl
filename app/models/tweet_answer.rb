class TweetAnswer < ActiveRecord::Base
  belongs_to :tweet, class_name: "TwitterParser::Tweet"
  belongs_to :answer, class_name: "Tagger::Answer"
end
