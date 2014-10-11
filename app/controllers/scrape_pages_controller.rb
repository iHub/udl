class ScrapePagesController < ApplicationController

	before_action :scrape_frequency_options, except: [:index, :show]

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
	end

	def create
		logger.debug "params[:scrape_session_id] => #{params[:scrape_session_id]}"
		@scrape_session = get_scrape_session(params[:scrape_session_id])
    	@scrape_page = @scrape_session.scrape_pages.build(scrape_page_params)

    	@scrape_page.continous_scrape 			= params[:scrape_page][:continous_scrape]
    	@scrape_page.override_session_settings  = params[:scrape_page][:override_session_settings]

    	logger.debug "params[:scrape_page][:continous_scrape] => #{params[:scrape_page][:continous_scrape]}"
    	logger.debug "@scrape_page.continous_scrape => #{@scrape_page.continous_scrape}"

    	# if has_app_access_token?

    	valid_url = @scrape_page.valid_page_url(@scrape_page.page_url, @scrape_session.id)
		
		# flash.now[:danger] = "Please initialize the application to continue"			
		# redirect_to new_app_setting_path and return
		
    	# valid_init_scrape = @scrape_page.valid_init_scrape_date(@scrape_page.initial_scrape_start, @scrape_page.initial_scrape_end)

    	if valid_url == "valid"		# valid_page_url

    		logger.debug "valid page url"
    		@scrape_page.scrape_frequency = frequency_minutes params[:scrape_page][:scrape_frequency_select]
    		@scrape_page.next_scrape_date = Time.now + @scrape_page.scrape_frequency

    		# logger.debug "------------------------------------------------"
    		# logger.debug "@scrape_page.next_scrape_date => #{@scrape_page.next_scrape_date}"

    	binding.pry
			if @scrape_page.save 		# has been saved?
				logger.debug "page saved;"

				success_message = "Your page has been added to the Session!"
				flash[:success] = success_message
				redirect_to scrape_session_scrape_pages_path

			else  # i didnt save, render form and try again
				flash[:danger] = @scrape_page.errors.inspect
				render 'new'
			end

    	elsif valid_url == "duplicate"		# invalid page because of duplication
    		logger.debug "duplicate page"
    		flash.now[:danger] =  "DUPLICATE: The page \" #{@scrape_page.page_url}\" already exists in this Session."
			render 'new'
		else								# invalid page - doesn't exist or koala error
			logger.debug "invalid url"
			flash.now[:danger] =  valid_url
			render 'new'
		end # @valid_page_url
	end


	def update
		@scrape_session = get_scrape_session(params[:scrape_session_id])
		@scrape_page = ScrapePage.find(params[:id])

		@scrape_page.scrape_frequency = frequency_minutes params[:scrape_page][:scrape_frequency_select]
		@scrape_page.next_scrape_date = Time.now + @scrape_page.scrape_frequency

		if @scrape_page.update_attributes(scrape_page_params)
			flash[:success] = "Your Page has been updated."
			redirect_to scrape_session_scrape_page_path
		else
			render edit_scrape_session_scrap_page_path(@scrape_page)
		end
	end

	def show
		@scrape_session = get_scrape_session(params[:scrape_session_id])
		
		@scrape_page = @scrape_session.scrape_pages.find(params[:id])

		@fb_posts = @scrape_page.fb_posts.paginate(page: params[:page])

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

		def frequency_minutes(scrape_frequency_select)
			frequency = case scrape_frequency_select
				when "10 Minutes"	then 10.minutes.to_i
				when "30 Minutes"	then 30.minutes.to_i
				when "1 Hour"		then 1.hour.to_i
				when "3 Hours"		then 3.hours.to_i
				when "6 Hours"		then 6.hours.to_i
				when "12 Hours"		then 12.hours.to_i
				when "Daily"		then 1.day.to_i
				when "Every 3 Days"	then 3.days.to_i
				when "Weekly"		then 1.week.to_i
				else  10.minutes.to_i
			end
		end

		
		def scrape_frequency_options
			scrape_frequency_options    = []
			scrape_frequency_options[1] = "10 Minutes"
			scrape_frequency_options[2] = "30 Minutes"
			scrape_frequency_options[3] = "1 Hour"
			scrape_frequency_options[4] = "3 Hours"
			scrape_frequency_options[5] = "6 Hours"
			scrape_frequency_options[6] = "12 Hours"
			scrape_frequency_options[7] = "Daily"
			scrape_frequency_options[8] = "Every 3 Days"
			scrape_frequency_options[9] = "Weekly"
			@scrape_frequencies = scrape_frequency_options
		end

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
