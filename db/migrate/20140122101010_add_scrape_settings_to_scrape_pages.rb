class AddScrapeSettingsToScrapePages < ActiveRecord::Migration
  def change
  	add_column :scrape_pages, :initial_scrape_end,   :datetime
  	add_column :scrape_pages, :next_scrape_date, 	 :datetime
  	add_column :scrape_pages, :continous_scrape,	 :boolean
  	add_column :scrape_pages, :initial_scrape_state, :string

  	rename_column :scrape_pages, :initial_scrape_date, :initial_scrape_start
  end
end
