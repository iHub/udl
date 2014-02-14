class AddPageTypeToScrapePages < ActiveRecord::Migration
  def change
    add_column :scrape_pages, :page_type, :string
  end
end
