class AddUserIdToScrapePages < ActiveRecord::Migration
  def change
    add_column :scrape_pages, :user_id, :integer
  end
end
