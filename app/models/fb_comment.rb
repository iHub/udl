class FbComment < ActiveRecord::Base

    belongs_to :fb_post

    before_save :comment_unique_to_this_post

    WILL_PAGINATE_COMMENTS_PER_PAGE = 50
    self.per_page = WILL_PAGINATE_COMMENTS_PER_PAGE

    def page_url
        this_post = FbPost.find(self.fb_post_id)
        this_page = ScrapePage.find(this_post.scrape_page_id)
        this_page.page_url  
    end

    def is_reply
        return "" if self.parent_id == "0"
        '<span class="glyphicon glyphicon-circle-arrow-up"></span>&nbsp;&nbsp;&nbsp;'
    end

    def offset(page)
        per_page = WILL_PAGINATE_COMMENTS_PER_PAGE
        if page.nil?
            @offset = 0 
        else
            @offset = WillPaginate::PageNumber(page).to_offset(per_page).to_i
        end
    end



    private

        def comment_unique_to_this_post
            same_comment =  FbComment.where(comment_id: self.comment_id, fb_post_id: self.fb_post_id)
            return false if same_comment.count > 0
        end
end
