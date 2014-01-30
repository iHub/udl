class DropNewPageLogs < ActiveRecord::Migration
  def change
    drop_table :new_page_logs
    drop_table :deleted_page_logs
    drop_table :init_scrape_logs
  end
end
