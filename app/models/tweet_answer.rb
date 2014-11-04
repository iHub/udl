class TweetAnswer < ActiveRecord::Base
  ######Tagging for Twitter
  belongs_to :tweet, class_name: "TwitterParser::Tweet"
  belongs_to :answer, class_name: "Tagger::Answer"


  ####Tagging for Disqus
  belongs_to :disqus_forum_comment
  belongs_to :disqus_answer, class_name: "Tagger::Answer", :foreign_key => "disqus_answer_id"
end
