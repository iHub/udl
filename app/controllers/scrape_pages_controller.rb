class ScrapePagesController < ApplicationController

	before_action :signed_in_user
	
	def index
		@scrape_session = get_scrape_session(params[:scrape_session_id])
    	@scrape_pages = @scrape_session.scrape_pages
    	@page_number = params[:page]
	end

	def edit
		@scrape_session = get_scrape_session(params[:scrape_session_id])
    	@scrape_page = @scrape_session.scrape_pages.find(params[:id])
	end

	def new
		@scrape_session = get_scrape_session(params[:scrape_session_id])
    	@scrape_page = @scrape_session.scrape_pages.build
    	@provide_default_instructions = true
	end

	def create
		@scrape_session = get_scrape_session(params[:scrape_session_id])
    	@scrape_page    = @scrape_session.scrape_pages.new(scrape_page_params)

    	@scrape_page.continous_scrape 			= params[:scrape_page][:continous_scrape]
    	@scrape_page.override_session_settings  = params[:scrape_page][:override_session_settings]
    	@scrape_page.scrape_frequency 			= frequency_minutes params[:scrape_page][:scrape_frequency_select]
		@scrape_page.user_id					= current_user.id

    	if @scrape_page.save 
    		ScrapePageLog.log_new_page_event(@scrape_page, current_user.id)
			flash[:success] = "Your page has been added to the Session!"
			redirect_to scrape_session_scrape_pages_path
		else
			flash.now[:danger] = @scrape_page.inspect + @scrape_page.errors.messages.to_s
			render :new
		end
	end

	def update
		@scrape_session = get_scrape_session(params[:scrape_session_id])
		@scrape_page = ScrapePage.find(params[:id])
		@scrape_page.continous_scrape = params[:scrape_page][:continous_scrape]
		@scrape_page.override_session_settings  = params[:scrape_page][:override_session_settings]
		@scrape_page.scrape_frequency = frequency_minutes params[:scrape_page][:scrape_frequency_select]

		if @scrape_page.update_attributes(scrape_page_params)
			ScrapePageLog.log_edit_page_event(@scrape_page, current_user.id)
			flash[:success] = "Your Page has been updated."
			redirect_to scrape_session_scrape_page_path
		else
			render 'edit'
		end
	end

	def show
		@scrape_session = get_scrape_session(params[:scrape_session_id])
		
		@scrape_page = @scrape_session.scrape_pages.find(params[:id])

		@fb_posts = @scrape_page.fb_posts.paginate(page: params[:page]).includes(:scrape_page)

		@page_number = params[:page]

		@selected_posts = {}
		@selected_posts[:source] = "Page"

		@search = FbPost.search(params[:q])
    	@search.build_condition
    	
	end

	def destroy
		@scrape_session = get_scrape_session(params[:scrape_session_id])
		scrape_page = @scrape_session.scrape_pages.find(params[:id]).destroy
		ScrapePageLog.log_delete_page_event(scrape_page, current_user.id)

		flash[:success] = "Page Deleted!"
		redirect_to scrape_session_scrape_pages_path
	end
	#-------------------------------------------------------------------------
	
	private

		# strong params
	    def scrape_page_params
	      params.require(:scrape_page).permit(:page_url,
	      									  :scrape_frequency_select,
									      	  :override_session_settings,
									      	  :continous_scrape )
	    end

end
