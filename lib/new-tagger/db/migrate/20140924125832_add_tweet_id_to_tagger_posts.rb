class AddTweetIdToTaggerPosts < ActiveRecord::Migration
  def change
  	remove_column :tagger_tagger_posts, :post_id, :integer
    add_reference :tagger_tagger_posts, :tweet, index: true
  end
end
