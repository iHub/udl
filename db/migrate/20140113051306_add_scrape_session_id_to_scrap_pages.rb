class AddScrapeSessionIdToScrapPages < ActiveRecord::Migration
  def change
  	rename_table :scrap_pages, :scrape_pages
  	add_column :scrape_pages, :scrape_session_id, :integer
    add_index  :scrape_pages, :scrape_session_id
  end
end
