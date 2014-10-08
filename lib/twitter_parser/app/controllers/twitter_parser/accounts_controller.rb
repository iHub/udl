require_dependency "twitter_parser/application_controller"

module TwitterParser
  class AccountsController < ApplicationController
	  before_action :set_account, only: [:show, :edit, :update, :destroy]

	  # GET /accounts
	  def index
	    @accounts = Account.all
	  end

	  # GET /accounts/1
	  def show
	  end

	  # GET /accounts/new
	  def new
	  	return redirect_to (request.referrer || root_url), alert: "You have to specify a scrape session to follow an account" unless request.url.scan("?ref=").present?
	    @id = request.url.split("?ref=").last
	    session[:scrape_session] = @id    
	    @scrape_session = ScrapeSession.find("#{@id}")
	    @account = Account.new
	    @scrape_session_selected = true
	  end

	  # GET /accounts/1/edit
	  def edit
	  end

	  # POST /accounts
	  def create
	  	return redirect_to (request.referrer || root_url), alert: "You have to specify a scrape session to follow an account" unless session[:scrape_session].present?
	  	@scrape_session = ScrapeSession.find("#{session[:scrape_session]}")
	    @account = Account.new(account_params.merge(scrape_session: @scrape_session))
	    @scrape_session_selected = true
	    if @account.save	    	
	      redirect_to main_app.scrape_session_url(@scrape_session), notice: 'account was successfully created.'
	      session[:scrape_session] = nil
	    else
	      render :new
	    end
	  end

	  # PATCH/PUT /accounts/1
	  def update
	    if @account.update(account_params)
	      redirect_to @account, notice: 'account was successfully updated.'
	    else
	      render :edit
	    end
	  end

	  # DELETE /accounts/1
	  def destroy
	    @account.destroy
	    redirect_to accounts_url, notice: 'account was successfully destroyed.'
	  end

	private
	  # Use callbacks to share common setup or constraints between actions.
	  def set_account
	    @account = Account.find(params[:id])
	  end

	  # Only allow a trusted parameter "white list" through.
	  def account_params
	    params.require(:account).permit(:username)
	  end
  end
end