class ChangeScrapeSessionsIdInAnnotators < ActiveRecord::Migration
  
  def change
  	rename_column :annotators, :scrape_sessions_id, :scrape_session_id
  end
end
