class CreateInitScrapeLogs < ActiveRecord::Migration
  def change
    create_table :init_scrape_logs do |t|

      t.integer   :scrape_page_id
      t.integer   :scrape_session_id      
      t.string    :scrape_page_url
      t.datetime  :scrape_start_date
      t.datetime  :scrape_end_date
      t.datetime  :scrape_process_start
      t.datetime  :scrape_process_end
      t.integer   :user_id
      t.string    :username
      t.integer   :init_comments
      t.integer   :init_posts

      t.timestamps
    end

    add_index  :init_scrape_logs, :user_id
    add_index  :init_scrape_logs, :scrape_page_id
    add_index  :init_scrape_logs, :scrape_session_id
  end
end
