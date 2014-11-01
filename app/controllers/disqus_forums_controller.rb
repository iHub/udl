class DisqusForumsController < ApplicationController
	before_filter :set_disqus_forum, except: [:index, :new, :create]

	def index
		return redirect_to (request.referrer || root_url), alert: "You have to specify a scrape session to view connected accounts" unless request.url.scan("?ref=").present?
    @id = request.url.split("?ref=").last
    @scrape_session = ScrapeSession.find("#{@id}")
    @scrape_session_selected = true
		@disqus_forums = @scrape_session.disqus_forums
	end

	def new
		return redirect_to (request.referrer || root_url), alert: "You have to specify a scrape session to follow an account" unless request.url.scan("?ref=").present?
	  @id = request.url.split("?ref=").last
	  session[:scrape_session] = @id    
	  @scrape_session = ScrapeSession.find("#{@id}")
		@title = "Create Disqus Forum"
		@disqus_forum = DisqusForum.new
		@scrape_session_selected = true
	end

	def create
		return redirect_to (request.referrer || root_url), alert: "You have to specify a scrape session to follow an account" unless session[:scrape_session].present?
		@scrape_session = ScrapeSession.find("#{session[:scrape_session]}")
	  @disqus_forum = DisqusForum.new(disqus_forum_params.merge({scrape_session: @scrape_session, user: current_user}))
		if @disqus_forum.save
			redirect_to @disqus_forum, notice: "Disqus forum successfully created"
		else
			render :new, alert: "Oooops, an error occured while creating your forum, Try again ..."
		end
	end

	def edit
		@title = "Edit #{@disqus_forum}"
	end

	def update
		if @disqus_forum.update(disqus_forum_params)
			redirect_to @disqus_forum, notice: "Disqus forum successfully updated"
		else
			render :edit, alert: "Oooops, an error occured while updating yout forum, Try again ..."
		end
	end

	def destroy
		@disqus_forum.destroy
		redirect_to (request.referrer || root_url), alert: "Forum successfully deleted!"
	end

private
	
	def disqus_forum_params
		params.require(:disqus_forum).permit(:forum_name)
	end

	def set_disqus_forum
		@disqus_forum = DisqusForum.find(params[:id]) if params[:id]
	end

end