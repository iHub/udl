class RenameColumnDisqusForumComment < ActiveRecord::Migration
  def change
  	rename_column :disqus_forum_comments, :author_message, :text
  end
end
