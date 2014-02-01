class RenameScrapeSettingsOnScrapeSession < ActiveRecord::Migration
  def change
        rename_column :scrape_sessions, :scrape_frequency, :session_scrape_frequency
        rename_column :scrape_sessions, :continous_scrape, :session_continuous_scrape
  end
end
