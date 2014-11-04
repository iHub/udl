class AddDisqusForumCommentToTweetAnswer < ActiveRecord::Migration
  def change
    add_reference :tweet_answers, :disqus_forum_comment, index: true
  end
end
