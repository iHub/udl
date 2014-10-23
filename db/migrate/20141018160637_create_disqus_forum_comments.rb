class CreateDisqusForumComments < ActiveRecord::Migration
  def change
    create_table :disqus_forum_comments do |t|
      t.references :disqus_forum, index: true
      t.string :points
      t.string :parent
      t.string :is_approved
      t.string :author_about
      t.string :author_username
      t.string :author_name
      t.string :author_url
      t.string :author_is_following
      t.string :author_is_follwed_by
      t.string :author_profile_url
      t.string :author_reputation
      t.string :author_location
      t.string :author_id
      t.string :author_disliked
      t.string :author_raw_message
      t.string :author_message
      t.string :author_created_at
      t.string :forum_id
      t.string :forum_thread
      t.string :forum_num_reports
      t.string :forum_likes
      t.string :forum_is_edited
      t.string :forum_message
      t.string :forum_is_spam
      t.string :forum_is_highlighted
      t.string :forum_user_score

      t.timestamps
    end
  end
end
