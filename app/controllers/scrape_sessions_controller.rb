class ScrapeSessionsController < ApplicationController

	#before_action :signed_in_user

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

		def scrape_session_params
			params.require(:scrape_session).permit(:name, :description)
		end
end