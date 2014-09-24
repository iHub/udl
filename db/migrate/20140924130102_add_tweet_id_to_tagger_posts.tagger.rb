# This migration comes from tagger (originally 20140924125832)
class AddTweetIdToTaggerPosts < ActiveRecord::Migration
  def change
  	remove_column :tagger_tagger_posts, :post_id, :integer
    add_reference :tagger_tagger_posts, :tweet, index: true
  end
end
