class CreateRegularScrapeLogs < ActiveRecord::Migration
  def change
    create_table :regular_scrape_logs do |t|
      t.integer   :scrape_session_id
      t.integer   :scrape_page_id
      t.datetime  :scrape_process_start
      t.datetime  :scrape_process_end
      t.integer   :collected_comments
      t.integer   :collected_posts
      t.datetime  :next_scrape_time

      t.timestamps
    end

    add_index  :regular_scrape_logs, :scrape_page_id
    add_index  :regular_scrape_logs, :scrape_session_id
  end
end
