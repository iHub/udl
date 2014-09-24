class ChangeIntToBigintInFacebookPosts < ActiveRecord::Migration
  def change
  	# change_column :facebook_posts, :comment_id, 	:integer
  	remove_column :facebook_posts, :from_user_id
  	remove_column :facebook_posts, :created_time
  	add_column :facebook_posts, :from_user_id, 	:integer
  	add_column :facebook_posts, :created_time, :datetime
  end
end
