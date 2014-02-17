class AddUpdatedTimeToFbPosts < ActiveRecord::Migration
  def change

    add_column :fb_posts, :updated_time, :datetime

  end
end
