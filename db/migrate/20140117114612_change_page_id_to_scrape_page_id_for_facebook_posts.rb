class ChangePageIdToScrapePageIdForFacebookPosts < ActiveRecord::Migration
  def change
  	rename_column :facebook_posts, :page_id, :scrape_page_id
  end
end
