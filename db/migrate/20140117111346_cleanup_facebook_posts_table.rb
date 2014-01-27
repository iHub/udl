class CleanupFacebookPostsTable < ActiveRecord::Migration
  def change
  	change_column :facebook_posts, :comment_id, 	:bigint
  	change_column :facebook_posts, :from_user_id, 	:bigint
  	change_column :facebook_posts, :created_time, 	:datetime
  end
end
