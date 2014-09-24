class CreateFacebookPosts < ActiveRecord::Migration
  def change
    create_table :facebook_posts do |t|

		t.integer	:comment_id
		t.integer	:page_id  			# belongs to page -> id on ULOG
		# t.string	:created_time 		# created at time on fb
		# t.string 	:from_user_id
		t.string	:from_user_name
		t.text		:message

		t.timestamps
    end

    add_index  :facebook_posts, :page_id
    add_index  :facebook_posts, :comment_id
  end
end
