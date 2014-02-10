class StaticPagesController < ApplicationController

  def home
    if signed_in?
  	    @scrape_sessions = current_user.scrape_sessions.limit(5) 
    end 
  	
  end

  def help
  end

  def about
  end
end
