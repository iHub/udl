class ScrapeSessionsController < ApplicationController

	#before_action :signed_in_user

	def index
		@scrape_sessions = current_user.scrape_sessions.paginate(page: params[:page])
	end

	def new
		@scrape_session = ScrapeSession.new
		@provide_default_instructions = true
	end

	def edit
		@scrape_session = get_scrape_session(params[:id])
	end

	def show
		@scrape_session = get_scrape_session(params[:id])
		@created_by 	= User.find(@scrape_session[:user_id]).username
		
		all_questions = @scrape_session.questions
		all_pages 	  = @scrape_session.scrape_pages

		@has_more_questions = true if all_questions.size > 5
		@has_more_pages	    = true if all_pages.size > 5

		@questions 		= all_questions.limit(5)
		@scrape_pages   = all_pages.limit(5)
	end

	def create
		scrape_session = ScrapeSession.new(scrape_session_params)
		scrape_session.user_id = current_user.id
    	scrape_session.allow_page_override  = params[:scrape_session][:allow_page_override]

    	scrape_session.session_continuous_scrape 	= params[:scrape_session][:session_continuous_scrape]
    	scrape_session.session_scrape_frequency 	= frequency_minutes params[:scrape_session][:scrape_frequency_select] if scrape_session.session_continuous_scrape

		if scrape_session.save
			log_scrape_session_event scrape_session, "create"
			flash[:success] = "Session created!"
			redirect_to root_url
		else
			render 'new'
		end
	end

	def update
		@scrape_session = ScrapeSession.find(params[:id])
    	@scrape_session.session_scrape_frequency 	= frequency_minutes params[:scrape_session][:scrape_frequency_select] || DEFAULT_SCRAPE_FREQUENCY
    	@scrape_session.session_continuous_scrape 	= params[:scrape_session][:session_continuous_scrape]

		if @scrape_session.update_attributes(scrape_session_params)
			log_scrape_session_event @scrape_session, "edit"
			flash[:success] = "Your Session has been updated."
			redirect_to scrape_session_path
		else
			render 'edit'
		end
	end


	def delete
		@scrape_session = ScrapeSession.find(params[:id])
	end

	def import
		@scrape_session = get_scrape_session(params[:id])
	end

	def upload
		@scrape_session = get_scrape_session(params[:id])
		if !params[:file].nil?
			@scrape_session.csv_import(params[:file])
			redirect_to scrape_session_path
		else
			flash.now[:danger] = "Please submit a valid file."
			render 'import'
		end
	end

	def batch_retro
		@scrape_session = get_scrape_session(params[:id])

		start_date =  params[:batch_retro_scrape_start].to_time.utc.to_i
		end_date   =  params[:batch_retro_scrape_end].to_time.utc.to_i

		selected_pages = ScrapePage.where(id: params[:scrape_page_ids])

		logger.debug "Selected pages => #{params[:scrape_page_ids].length}"

		selected_pages.each do |this_page|
			this_page.retro_scrape start_date, end_date
		end

		logger.debug "selected_pages => #{selected_pages.inspect}"
		logger.debug "retro-params => #{params.inspect}"
		flash[:success] = "Batch Retro scrape in progress"
		redirect_to scrape_session_path
	end

	def destroy
		scrape_session = ScrapeSession.find(params[:id]).destroy
		log_scrape_session_event scrape_session, "delete"
		flash[:danger] = "Session '#{scrape_session.name}' deleted"
		redirect_to root_url
	end

	private

		def scrape_session_params
			params.require(:scrape_session).permit(:name, 
												   :description,
												   :allow_page_override,
										      	   :scrape_frequency,
										      	   :next_scrape_date,
										      	   :continous_scrape )
		end

		def log_scrape_session_event(scrape_session, event)
			event_params = {}
			event_params[:scrape_session_id] 		= scrape_session.id
			event_params[:scrape_session_name] 	    = scrape_session.name
			event_params[:event_time]  				= Time.now
			event_params[:user_id]     				= current_user.id
			event_params[:username]    				= current_user.username
			event_params[:event_type]  				= event

			event_params[:session_scrape_frequency]     = scrape_session.session_scrape_frequency
			event_params[:session_next_scrape_date]		= scrape_session.session_next_scrape_date
			event_params[:session_continuous_scrape]	= scrape_session.session_continuous_scrape
			event_params[:allow_page_override]			= scrape_session.allow_page_override
			event_params[:scrape_page_count]			= scrape_session.total_pages
			event_params[:fb_posts_count]				= scrape_session.total_posts
			event_params[:fb_comments_count]			= scrape_session.total_comments

			log_event = ScrapeSessionLog.new(event_params)

			if log_event.save
				logger.debug "scrape_session Log : #{event}"
			end 

	    end
end