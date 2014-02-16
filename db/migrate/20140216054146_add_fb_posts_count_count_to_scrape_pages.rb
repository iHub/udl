class AddFbPostsCountCountToScrapePages < ActiveRecord::Migration
  def change
    add_column :scrape_pages, :fb_posts_count, :integer, :default => 0
  end
end
