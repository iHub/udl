class FbPostsController < ApplicationController

    before_action :signed_in_user
    
    def index
        @page_number = params[:page]

        if !params[:scrape_session_id].nil?
            @scrape_session = get_scrape_session(params[:scrape_session_id])            
            @fb_posts = @scrape_session.fb_posts.paginate(:page => params[:page]).includes(:scrape_page)
            @fb_posts_scope = "session"
        elsif !params[:scrape_page_id].nil?
            @scrape_pages    = ScrapePage.find(params[:scrape_page_id])      
            @fb_posts  = @scrape_pages.fb_posts.paginate(:page => params[:page]).includes(:scrape_page)
            @fb_posts_scope = "page"
        end

    end

    def show
        @page_number = params[:page]

        @scrape_page = ScrapePage.find(params[:scrape_page_id])

        scrape_session_id =  params[:scrape_session_id] || @scrape_page.scrape_session_id

        @scrape_session = get_scrape_session(scrape_session_id)
        
        @fb_post = FbPost.find(params[:id])
        @fb_comments = @fb_post.fb_comments.paginate(:page => params[:page]).includes(:fb_post)
    end

    def create
        @scrape_page    =  ScrapePage.find(params[:scrape_page_id])
        @facebook_post  =  @scrape_page.fb_posts.build(fb_post_params)

        if @facebook_post.save
            flash[:success] = "Post Added!" 
            redirect_to scrape_session_scrape_page_fb_posts_path
        else
            render 'new'
        end
    end

    private

    # strong params
        def fb_post_params
        params.require(:fb_post).permit(:created_time,
                                          :fb_page_id,
                                          :fb_post_id,
                                          :message,
                                          :scrape_page_id)
        end

end
