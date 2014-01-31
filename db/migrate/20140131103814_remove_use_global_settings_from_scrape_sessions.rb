class RemoveUseGlobalSettingsFromScrapeSessions < ActiveRecord::Migration
  def change
    remove_column :scrape_sessions, :use_global_settings
  end
end
