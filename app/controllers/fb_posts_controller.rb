class FbPostsController < ApplicationController

    def index
        
        @search = FbPost.search(params[:q])
        @search.build_condition
        @page_number = params[:page]

        if !params[:scrape_session_id].nil?
            @scrape_session = ScrapeSession.find(params[:scrape_session_id])            
            @fb_posts = @scrape_session.fb_posts.paginate(:page => params[:page])
            @fb_posts_scope = "session"
        elsif !params[:scrape_page_id].nil?
            @scrape_pages    = ScrapePage.find(params[:scrape_page_id])      
            @fb_posts  = @scrape_pages.fb_posts.paginate(:page => params[:page])
            @fb_posts_scope = "page"
        end

    end

    def show
        @search = FbPost.search(params[:q])
        @search.build_condition
        @page_number = params[:page]
        
        @scrape_session = ScrapeSession.find(params[:scrape_session_id])
        @scrape_page = ScrapePage.find(params[:scrape_page_id])
        @fb_post = FbPost.find(params[:id])
        @fb_comments = @fb_post.fb_comments.paginate(:page => params[:page])
    end

    def search
        @selected_posts = {}
        @search = FbPost.search(params[:q])
        @search_params = params[:q]
        @fb_posts = @search.result(distinct: "true")
        @selected_posts[:source] = "search"
    end


    def create
        @scrape_page    =  ScrapePage.find(params[:scrape_page_id])
        @facebook_post  =  @scrape_page.fb_posts.build(facebook_post_params)

        if @facebook_post.save
            flash[:success] = "Post Added!" 
            redirect_to scrape_session_scrape_page_fb_posts_path
        else
            render 'new'
        end
    end

    private

    # strong params
        def facebook_post_params
        params.require(:fb_post).permit(:created_time,
                                          :fb_page_id,
                                          :fb_post_id,
                                          :message,
                                          :scrape_page_id)
        end

end
