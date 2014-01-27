class AddScrapePageIdToFbPosts < ActiveRecord::Migration
  def change
    add_column :fb_posts, :scrape_page_id, :integer

    add_index  :fb_posts, :scrape_page_id
  end
end
