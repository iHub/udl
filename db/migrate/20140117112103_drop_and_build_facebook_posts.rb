class DropAndBuildFacebookPosts < ActiveRecord::Migration
  def change
  	drop_table :facebook_posts

  	create_table :facebook_posts do |t|

  		t.integer	:page_id  			# belongs to page -> id on ULOG
  										# the rest of the columns are from fb
		t.integer	:comment_id
		t.integer 	:from_user_id
		t.datetime	:created_time 		# created at time on fb
		t.string	:from_user_name		# the user name
		t.text		:message			# the comment

		t.timestamps
    end

    add_index  :facebook_posts, :page_id
    add_index  :facebook_posts, :comment_id
  end
end
