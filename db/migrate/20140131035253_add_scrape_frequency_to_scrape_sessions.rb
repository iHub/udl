class AddScrapeFrequencyToScrapeSessions < ActiveRecord::Migration
  def change
    add_column :scrape_sessions, :scrape_frequency, :integer
    add_column :scrape_sessions, :continous_scrape, :boolean
    add_column :scrape_sessions, :next_scrape_date, :datetime
  end
end
