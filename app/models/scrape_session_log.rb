class ScrapeSessionLog < ActiveRecord::Base

    def record_log_event(scrape_session, user_id, event_type)
        user = User.find(user_id)
        
        event_params = {}
        event_params[:scrape_session_id]        = scrape_session.id
        event_params[:scrape_session_name]      = scrape_session.name
        event_params[:event_time]               = Time.now
        event_params[:user_id]                  = user_id
        event_params[:username]                 = user.username
        event_params[:event_type]               = event_type

        event_params[:session_scrape_frequency]     = scrape_session.session_scrape_frequency
        event_params[:session_next_scrape_date]     = scrape_session.session_next_scrape_date
        event_params[:session_continuous_scrape]    = scrape_session.session_continuous_scrape
        event_params[:allow_page_override]          = scrape_session.allow_page_override
        event_params[:scrape_page_count]            = scrape_session.total_pages
        event_params[:fb_posts_count]               = scrape_session.total_posts
        event_params[:fb_comments_count]            = scrape_session.total_comments

        log_event = ScrapeSessionLog.new(event_params)

        if log_event.save
            logger.debug "scrape_session Log : #{event_type}"
        end 
    end 
end
