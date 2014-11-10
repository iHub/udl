module Tagger
  class TaggerPost < ActiveRecord::Base
    belongs_to :user
    belongs_to :tweet, class_name: "TwitterParser::Tweet", foreign_key: "tweet_id"
    belongs_to :disqus_forum_comment, class_name: "DisqusForumComment", foreign_key: "disqus_forum_comment_id"
    # validates_uniqueness_of :user_id, scope: :tweet_id
  end
end
