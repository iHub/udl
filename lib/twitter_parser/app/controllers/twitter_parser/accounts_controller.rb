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
	    @account = Account.new
	  end

	  # GET /accounts/1/edit
	  def edit
	  end

	  # POST /accounts
	  def create
	    @account = Account.new(account_params)
	    if @account.save
	      redirect_to accounts_url, notice: 'account was successfully created.'
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