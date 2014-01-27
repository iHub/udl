class DropFacebookPosts < ActiveRecord::Migration
  def change
    drop_table :facebook_posts
  end
end
