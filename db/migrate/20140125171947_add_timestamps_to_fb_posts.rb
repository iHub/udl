class AddTimestampsToFbPosts < ActiveRecord::Migration
  def change
    add_column :fb_posts, :created_at, :datetime
    add_column :fb_posts, :updated_at, :datetime
  end
end
