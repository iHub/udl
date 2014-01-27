class ChangeScrapeSessionsIdInUser < ActiveRecord::Migration
  def change
  	rename_column :questions, :scrape_sessions_id, :scrape_session_id
  end
end
