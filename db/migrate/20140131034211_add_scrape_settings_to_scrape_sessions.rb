class AddScrapeSettingsToScrapeSessions < ActiveRecord::Migration
  def change
    add_column :scrape_sessions, :allow_page_override, :boolean
    add_column :scrape_sessions, :use_global_settings, :boolean

    add_index :scrape_sessions, :allow_page_override
    add_index :scrape_sessions, :use_global_settings
    
  end
end
