class AddFbPageIdToScrapePages < ActiveRecord::Migration
  def change
    add_column :scrape_pages, :fb_page_id, :string

    add_index  :scrape_pages, :fb_page_id
  end
end
