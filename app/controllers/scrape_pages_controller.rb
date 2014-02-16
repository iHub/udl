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
    	@scrape_page = @scrape_session.scrape_pages.build(scrape_page_params)

    	@scrape_page.continous_scrape 			= params[:scrape_page][:continous_scrape]
    	@scrape_page.override_session_settings  = params[:scrape_page][:override_session_settings]
    	@scrape_page.scrape_frequency 			= frequency_minutes params[:scrape_page][:scrape_frequency_select]
		@scrape_page.user_id					= current_user.id
    	if @scrape_page.save 		# has been saved?
			success_message = "Your page has been added to the Session!"
			flash[:success] = success_message
			redirect_to scrape_session_scrape_pages_path
		else 
			render 'new'
		end
	end

	def update
		@scrape_session = get_scrape_session(params[:scrape_session_id])
		@scrape_page = ScrapePage.find(params[:id])
		@scrape_page.continous_scrape = params[:scrape_page][:continous_scrape]
		@scrape_page.override_session_settings  = params[:scrape_page][:override_session_settings]
		@scrape_page.scrape_frequency = frequency_minutes params[:scrape_page][:scrape_frequency_select]

		if @scrape_page.update_attributes(scrape_page_params)
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
		flash[:success] = "Page Deleted!"
		redirect_to scrape_session_scrape_pages_path
	end

	############################################################
	
	private

		

		
		

		# strong params
	    def scrape_page_params
	      params.require(:scrape_page).permit(:page_url, 
									      	  # :scrape_frequency,
									      	  :scrape_frequency_select,
									      	  :override_session_settings,
									      	  :next_scrape_date,
									      	  :continous_scrape )
	    end

end
