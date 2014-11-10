class AddDisqusForumIdToTweetTaggers < ActiveRecord::Migration
  def change
    add_reference :tweet_taggers, :disqus_forum_comment, index: true
  end
end
