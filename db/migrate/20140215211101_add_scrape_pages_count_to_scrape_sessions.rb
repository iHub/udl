class AddScrapePagesCountToScrapeSessions < ActiveRecord::Migration
  def change
    add_column :scrape_sessions, :scrape_pages_count, :integer, :default => 0
  end
end
