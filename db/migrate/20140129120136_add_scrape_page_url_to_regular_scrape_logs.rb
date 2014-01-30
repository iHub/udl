class AddScrapePageUrlToRegularScrapeLogs < ActiveRecord::Migration
  def change
    add_column :regular_scrape_logs, :scrape_page_url, :string
  end
end
