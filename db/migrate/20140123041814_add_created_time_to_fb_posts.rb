class AddCreatedTimeToFbPosts < ActiveRecord::Migration
  def change
    add_column :fb_posts, :created_time, :datetime
  end
end
