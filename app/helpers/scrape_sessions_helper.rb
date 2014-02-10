module ScrapeSessionsHelper

    def get_scrape_session(scrape_session_id)
        scrape_session = ScrapeSession.find(scrape_session_id)
        @scrape_session_selected = true if scrape_session
        scrape_session
    end
end