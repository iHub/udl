class StaticPagesController < ApplicationController

  def home
  	@scrape_sessions = current_user.scrape_sessions.paginate(page: params[:page]) if signed_in?
  	# @user = current_user if signed_in?
  end

  def help
  end

  def about
  end
end
