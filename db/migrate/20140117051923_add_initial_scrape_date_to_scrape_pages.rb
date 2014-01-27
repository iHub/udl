class AddInitialScrapeDateToScrapePages < ActiveRecord::Migration
  def change
    add_column :scrape_pages, :initial_scrape_date, :datetime
  end
end
