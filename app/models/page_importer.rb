class PageImporter

    def initialize(file, scrape_session, user_id)
        @file           = file
        @scrape_session = scrape_session    
        @user           = User.find(user_id)
    end

    def validate_file(uploaded_file)
        
    end

    def save_scrape_pages_array

        import_pages.each do |page|
            
            import_page = scrape_session.scrape_page.new(page_url:, page[:page_url] )
            
            if import_page.save
                ScrapePageLog.log_new_page_event(import_page, @user.id)
                #--- log this
            end
        end
    end

    # def file_to_scrape_pages_array
    #     begin
    #         import_pages = SmarterCSV.process(file.tempfile)
    #     rescue Exception => e
    #         self.errors.add(:file, "#{e.message}")
    #         return false
    #     end
        
    # end
end