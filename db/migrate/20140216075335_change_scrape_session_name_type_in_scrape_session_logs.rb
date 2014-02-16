class ChangeScrapeSessionNameTypeInScrapeSessionLogs < ActiveRecord::Migration
  def change
    change_column :scrape_session_logs, :scrape_session_name, :string
  end
end
