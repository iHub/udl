class ScrapePageLog < ActiveRecord::Base

    def self.log_new_page_event(scrape_page, user_id)
        log_event = self.new.get_page_attributes scrape_page, user_id
        log_event[:event_type] = "create"
        ScrapePageLog.create(log_event)
    end

    def self.log_edit_page_event(scrape_page, user_id)
        log_event = self.new.get_page_attributes scrape_page, user_id
        log_event[:event_type] = "edit"
        ScrapePageLog.create(log_event)
    end

    def self.log_delete_page_event(scrape_page, user_id)
        log_event = self.new.get_page_attributes scrape_page, user_id
        log_event[:event_type] = "delete"
        ScrapePageLog.create(log_event)
    end


    def get_page_attributes(scrape_page, user_id)
        user = User.find(user_id)
        
        event_params = {}
        event_params[:scrape_page_id]        = scrape_page.id
        event_params[:scrape_session_id]     = scrape_page.scrape_session_id
        event_params[:page_url]              = scrape_page.page_url
        event_params[:fb_page_id]            = scrape_page.fb_page_id
        event_params[:event_time]            = Time.now
        event_params[:user_id]               = user_id
        event_params[:username]              = user.username

        event_params[:scrape_frequency]             = scrape_page.scrape_frequency
        event_params[:next_scrape_date]             = scrape_page.next_scrape_date
        event_params[:continous_scrape]             = scrape_page.continous_scrape
        event_params[:override_session_settings]    = scrape_page.override_session_settings

        event_params[:fb_posts_count]               = scrape_page.fb_posts_count
        event_params[:fb_comments_count]            = scrape_page.total_comments

        event_params
    end

end
