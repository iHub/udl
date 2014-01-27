class ChangeIdsToStringsInFacebookPosts < ActiveRecord::Migration
  def change
  	change_column :facebook_posts, :comment_id, 	:string
  	change_column :facebook_posts, :from_user_id, 	:string
  end
end
