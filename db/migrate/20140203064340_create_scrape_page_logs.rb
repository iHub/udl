class CreateScrapePageLogs < ActiveRecord::Migration
  def change
    create_table :scrape_page_logs do |t|
      t.integer  :user_id
      t.string   :username
      t.integer  :scrape_page_id
      t.string   :page_url
      t.integer  :scrape_session_id
      t.string   :fb_page_id
      t.integer  :scrape_frequency
      t.datetime :event_time
      t.string   :event_type
      t.datetime :next_scrape_date
      t.boolean  :continous_scrape
      t.boolean  :override_session_settings
      t.integer  :fb_posts_count
      t.integer  :fb_comments_count

      t.timestamps
    end

    add_index  :scrape_page_logs, :user_id
    add_index  :scrape_page_logs, :scrape_page_id
    add_index  :scrape_page_logs, :scrape_session_id
  end
end
