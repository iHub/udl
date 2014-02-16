class AddFbCommentsCountToFbPosts < ActiveRecord::Migration
  def change
    add_column :fb_posts, :fb_comments_count, :integer, :default => 0
  end
end
