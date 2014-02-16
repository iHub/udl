class FbComment < ActiveRecord::Base

    belongs_to :fb_post, counter_cache: true  
    before_save :comment_unique_to_this_post

    # default_scope -> { order('created_at DESC') }

    WILL_PAGINATE_COMMENTS_PER_PAGE = 50
    self.per_page = WILL_PAGINATE_COMMENTS_PER_PAGE

    def page_url
        self.fb_post.page_url  
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
