=begin
	This is a join table which asociates tweets/posts to the how 
	they were annswered or what question was assigned to them.
=end


class TweetAnswer < ActiveRecord::Base
  belongs_to :tweet, class_name: "TwitterParser::Tweet"
  belongs_to :answer, class_name: "Tagger::Answer"
end
