class FbCommentsController < ApplicationController

  before_action :signed_in_user
  
  def index
    
    @search = FbComment.search(params[:q])
    @search.build_condition

    @page_number = params[:page]

    if !params[:scrape_session_id].nil?    # scrapge session id not in params
        @scrape_session = get_scrape_session(params[:scrape_session_id])
        @fb_comments = @scrape_session.fb_comments.paginate(:page => params[:page])
        @fb_comments_scope = "session"
    end

    if !params[:scrape_page_id].nil?    # scrapge session id not in params
        @scrape_page  = ScrapePage.find(params[:scrape_page_id])
        @fb_comments = @scrape_page.fb_comments.paginate(:page => params[:page])
        @fb_comments_scope = "page"
    end

    if !params[:fb_post_id].nil?    # scrapge session id not in params
        @fb_post  = FbPost.find(params[:fb_post_id])
        @fb_comments = @fb_post.fb_comments.paginate(:page => params[:page])
        @fb_comments_scope = "post"
    end

  end

  def search
    @fb_comments_scope = "search"
    @search = FbComment.search(params[:q])
    @search_params = params[:q]
    @fb_comments = @search.result(distinct: "true")
  end

  def show
  end
end
