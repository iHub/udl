class ChangeScrapeSessionsIdInAnnotations < ActiveRecord::Migration
  def change
  	rename_column :annotations, :scrape_sessions_id, :scrape_session_id
  end
end
