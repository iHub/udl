class AddRegularPostToFbPosts < ActiveRecord::Migration
  def change
    add_column :fb_posts, :regular_post, :boolean, :default => true
  end
end
