class RemoveInitScrapeFromScrapePages < ActiveRecord::Migration
  def change
    remove_column :scrape_pages, :initial_scrape_start
    remove_column :scrape_pages, :initial_scrape_end
    remove_column :scrape_pages, :initial_scrape_state
  end
end
