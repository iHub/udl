class ScrapePageLog < ActiveRecord::Base

    def self.log_page_event(scrape_page, user_id, event_type)

        user = User.find(user_id)
        
        event_params = {}
        event_params[:scrape_page_id]        = scrape_page.id
        event_params[:scrape_session_id]     = scrape_page.scrape_session_id
        event_params[:page_url]              = scrape_page.page_url
        event_params[:fb_page_id]            = scrape_page.fb_page_id
        event_params[:event_time]            = Time.now
        event_params[:user_id]               = user_id
        event_params[:username]              = user.username
        event_params[:event_type]            = event_type

        event_params[:scrape_frequency]             = scrape_page.scrape_frequency
        event_params[:next_scrape_date]             = scrape_page.next_scrape_date
        event_params[:continous_scrape]             = scrape_page.continous_scrape
        event_params[:override_session_settings]    = scrape_page.override_session_settings

        event_params[:fb_posts_count]               = scrape_page.fb_posts_count
        event_params[:fb_comments_count]            = scrape_page.total_comments

        log_page_event = ScrapePageLog.new(event_params)

        if log_page_event.save
            logger.debug "scrape_page Log : #{event_type}"
        end 
    end 

end
