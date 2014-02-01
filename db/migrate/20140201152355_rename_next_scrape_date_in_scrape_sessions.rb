class RenameNextScrapeDateInScrapeSessions < ActiveRecord::Migration
  def change
    rename_column :scrape_sessions, :next_scrape_date, :session_next_scrape_date
  end
end
