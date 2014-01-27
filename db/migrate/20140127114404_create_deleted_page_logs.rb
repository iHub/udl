class CreateDeletedPageLogs < ActiveRecord::Migration
  def change
    create_table :deleted_page_logs do |t|
      t.integer   :scrape_page_id
      t.integer   :scrape_session_id      
      t.string    :scrape_page_url
      t.datetime  :event_time
      t.integer   :user_id
      t.string    :username
      t.string    :event_type

      t.timestamps
    end
    
    add_index  :deleted_page_logs, :user_id
    add_index  :deleted_page_logs, :scrape_page_id
    add_index  :deleted_page_logs, :scrape_session_id
  end
end
