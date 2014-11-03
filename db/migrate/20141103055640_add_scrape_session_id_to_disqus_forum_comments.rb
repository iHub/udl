class AddScrapeSessionIdToDisqusForumComments < ActiveRecord::Migration
  def change
    add_reference :disqus_forum_comments, :scrape_session, index: true
    add_column :disqus_forum_comments, :forum_name, :string
  end
end
