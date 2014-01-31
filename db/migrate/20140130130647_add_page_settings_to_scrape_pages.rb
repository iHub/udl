class AddPageSettingsToScrapePages < ActiveRecord::Migration
  def change
    add_column :scrape_pages, :override_session_settings, :boolean
  end
end
