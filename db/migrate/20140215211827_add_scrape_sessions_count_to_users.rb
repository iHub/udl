class AddScrapeSessionsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :scrape_sessions_count, :integer, :default => 0
  end
end
