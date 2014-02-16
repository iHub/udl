class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    include SessionsHelper
    include ScrapeSessionsHelper

    def frequency_minutes(scrape_frequency_select)
        frequency = case scrape_frequency_select
            when "10 Minutes"   then 10.minutes.to_i
            when "30 Minutes"   then 30.minutes.to_i
            when "1 Hour"       then 1.hour.to_i
            when "3 Hours"      then 3.hours.to_i
            when "6 Hours"      then 6.hours.to_i
            when "12 Hours"     then 12.hours.to_i
            when "Daily"        then 1.day.to_i
            when "Every 3 Days" then 3.days.to_i
            when "Weekly"       then 1.week.to_i
            else  10.minutes.to_i
        end
    end

end
