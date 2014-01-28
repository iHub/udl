class FacebookPostsController < ApplicationController

  def index
  	@scrape_session = ScrapeSession.find(params[:scrape_session_id])
    @search = FacebookPost.search(params[:q])
    @search.build_condition

    @selected_posts = {}
    if params[:scrape_page_id].nil?
      @scrape_pages = @scrape_session.scrape_pages
      @facebook_posts = FacebookPost.where(scrape_page_id: @scrape_pages).paginate(:page => params[:page])
      @selected_posts[:source] = "session"
      logger.debug " Facebook posts =>  #{@facebook_posts.inspect}"
    else
      @scrape_pages    = ScrapePage.find(params[:scrape_page_id])      
      @facebook_posts  = @scrape_pages.facebook_posts.paginate(:page => params[:page])
      @selected_posts[:source] = "page"
    end

    logger.debug "params[:scrape_page_id] is nil =>  #{params[:scrape_page_id].nil?}"

  end

  def search
    @selected_posts = {}
    @search = FacebookPost.search(params[:q])
    @search_params = params[:q]
    @facebook_posts = @search.result(distinct: "true")
    @selected_posts[:source] = "search"
  end

  def show
  	@scrape_session = ScrapeSession.find(params[:scrape_session_id])
    @scrape_page = ScrapePage.find(params[:scrape_page_id])
    @facebook_post = @scrape_page.answer.find(params[:id])
  end

  def create
  	@scrape_page 	=  ScrapePage.find(params[:scrape_page_id])
  	@facebook_post  =  @scrape_page.facebook_posts.build(facebook_post_params)

  	if @facebook_post.save
  		flash[:success] = "Post Added!" 
      redirect_to scrape_session_scrape_page_facebook_posts_path
  	else
  		render 'new'
  	end
  end

  private

	# strong params
    def facebook_post_params
      params.require(:facebook_post).permit(:comment_id, 
								      	  :created_time, 
								      	  :from_user_id,
								      	  :from_user_name,
								      	  :message)
    end

end
