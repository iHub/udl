class CreateFbComments < ActiveRecord::Migration
  def change
    create_table :fb_comments do |t|
        t.integer  :fb_post_id
        t.string   :comment_id
        t.string   :from_user_id
        t.datetime :created_time
        t.string   :from_user_name
        t.text     :message

        t.timestamps
    end

    add_index  :fb_comments, :fb_post_id
    add_index  :fb_comments, :comment_id
  end
end

