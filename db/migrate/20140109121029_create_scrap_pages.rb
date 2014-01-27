class CreateScrapPages < ActiveRecord::Migration
  def change
    create_table :scrap_pages do |t|
      t.string :page_url
      t.integer :scrape_frequency

      t.timestamps
    end
  end
end
