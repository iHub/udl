class CreateNewPageLogs < ActiveRecord::Migration
  def change
    create_table :new_page_logs do |t|
      t.integer   :scrape_page_id
      t.integer   :scrape_session_id      
      t.string    :scrape_page_url
      t.datetime  :created_time
      t.integer   :user_id
      t.string    :username
      t.boolean   :init_scrape
      t.integer   :init_scrape_log_id
      
      t.timestamps
    end

    add_index  :new_page_logs, :user_id
    add_index  :new_page_logs, :scrape_page_id
    add_index  :new_page_logs, :scrape_session_id
  end
end
