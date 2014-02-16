class AddQuestionsCountToScrapeSessions < ActiveRecord::Migration
  def change
    add_column :scrape_sessions, :questions_count, :integer, :default => 0
  end
end
