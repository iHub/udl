class FbPost < ActiveRecord::Base

    # associations
    belongs_to :scrape_page, counter_cache: true    
    has_many   :fb_comments, dependent: :destroy

    default_scope -> { order('created_at DESC') }
    
    # validates_uniqueness_of :fb_post_id, scope: :scrape_page_id
    before_save :post_unique_to_this_page

    WILL_PAGINATE_POSTS_PER_PAGE = 50
    self.per_page = WILL_PAGINATE_POSTS_PER_PAGE

    def page_url
        self.scrape_page.page_url  
    end

    def offset(page)
        per_page = WILL_PAGINATE_POSTS_PER_PAGE
        if page.nil?
            @offset = 0 
        else
            @offset = WillPaginate::PageNumber(page).to_offset(per_page).to_i
        end
    end

    private

        def post_unique_to_this_page
            logger.debug "self.fb_post_id => #{self.fb_post_id}"
            logger.debug "self.scrape_page_id => #{self.scrape_page_id}"
            logger.debug "---------------------------------------------"
            same_post = FbPost.where(fb_post_id: self.fb_post_id, scrape_page_id: self.scrape_page_id)
            logger.debug "same_post.size => #{same_post.size}"
            return false if same_post.size > 0
        end

end
