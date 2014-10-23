class AddFieldToDisqusForumComments < ActiveRecord::Migration
  def change
		remove_column :disqus_forum_comments, :author_raw_message, :string
		remove_column :disqus_forum_comments, :author_message, :string
		remove_column :disqus_forum_comments, :forum_message, :string

		add_column :disqus_forum_comments, :author_raw_message, :text
		add_column :disqus_forum_comments, :author_message, :text
		add_column :disqus_forum_comments, :forum_message, :text
  end
end
