class CreateFbPosts < ActiveRecord::Migration
  def change
    create_table :fb_posts do |t|
      t.string :fb_post_id
      t.text :message
      t.string :fb_page_id
    end

    add_index  :fb_posts, :fb_post_id
    add_index  :fb_posts, :fb_page_id
  end
end
