class TweetTagger < ActiveRecord::Base
	belongs_to :disqus_forum_comment
  belongs_to :tweet, class_name: "TwitterParser::Tweet"
  belongs_to :user
end
