class CreateScrapeSessionLogs < ActiveRecord::Migration
    def change
        create_table :scrape_session_logs do |t|
            t.integer  :user_id
            t.string   :username
            t.integer  :scrape_session_name
            t.integer  :scrape_session_id
            t.datetime :event_time
            t.string   :event_type
            t.integer  :session_scrape_frequency
            t.datetime :session_next_scrape_date
            t.boolean  :session_continuous_scrape
            t.boolean  :allow_page_override
            t.integer  :scrape_page_count
            t.integer  :fb_posts_count
            t.integer  :fb_comments_count

            t.timestamps
        end

        add_index  :scrape_session_logs, :user_id
        add_index  :scrape_session_logs, :scrape_session_id
    end
end
