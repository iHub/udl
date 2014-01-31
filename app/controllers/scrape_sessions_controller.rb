class ScrapeSessionsController < ApplicationController

	#before_action :signed_in_user
	before_action :scrape_frequency_options, except: [:index, :show]

	def index
		# @scrape_sessions = ScrapeSession.paginate(page: params[:page])
		@scrape_sessions = current_user.scrape_sessions
	end

	def new
		@scrape_session = ScrapeSession.new
	end

	def edit
		@scrape_session = ScrapeSession.find(params[:id])
	end

	def show
		@scrape_session = ScrapeSession.find(params[:id])
		@created_by 	= User.find(@scrape_session[:user_id]).username
		@questions 		= @scrape_session.questions
		@scrape_pages   = @scrape_session.scrape_pages
	end

	def create
		scrape_session = ScrapeSession.new(scrape_session_params)
		scrape_session.user_id = current_user.id

		
    	scrape_session.allow_page_override  = params[:scrape_session][:allow_page_override]
    	scrape_session.use_global_settings  = params[:scrape_session][:use_global_settings]

    	scrape_session.continous_scrape 	= params[:scrape_session][:continous_scrape]
    	
    	scrape_session.scrape_frequency 	= frequency_minutes params[:scrape_session][:scrape_frequency_select] if scrape_session.continous_scrape
    	scrape_session.next_scrape_date 	= Time.now + scrape_session.scrape_frequency if scrape_session.continous_scrape

		if scrape_session.save
			flash[:success] = "Session created!"
			redirect_to root_url
		else
			render 'scrape_sessions/new'
		end
	end

	def delete
		@scrape_session = ScrapeSession.find(params[:id])
	end

	def destroy
		# scrape_session = ScrapeSession.find(params[:id]).destroy

		scrape_session = ScrapeSession.find(params[:id]).destroy

		flash[:danger] = "Session '#{scrape_session.name}' deleted"
		redirect_to root_url
	end

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

		def scrape_session_params
			params.require(:scrape_session).permit(:name, 
												   :description,
												   :scrape_frequency_select,
										      	   :override_session_settings,
										      	   :next_scrape_date,
										      	   :continous_scrape )
		end
end