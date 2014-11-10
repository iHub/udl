class AddDisqusForumIdToTaggerTaggerPosts < ActiveRecord::Migration
  def change
    add_reference :tagger_tagger_posts, :disqus_forum_comment, index: true
  end
end
