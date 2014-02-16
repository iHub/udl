module ApplicationHelper

  	# Returns the full title on a per-page basis.
	def full_title(page_title)
		base_title = "Umati Data Logger"
		if page_title.empty?
		  base_title
		else
		  "#{base_title} | #{page_title}"
		end
	end

	def flash_class(level)
		logger.debug "level #{level}"
		case level
		    when "notice" 	then "alert alert-info"
		    when "success" 	then "alert alert-success"
		    when "error" 	then "alert alert-error"
		    when "alert" 	then "alert alert-danger"
		end
	end

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

	def scrape_frequency
		scrape_frequency    = []
		scrape_frequency[0] = "10 Minutes"
		scrape_frequency[1] = "30 Minutes"
		scrape_frequency[2] = "1 Hour"
		scrape_frequency[3] = "3 Hours"
		scrape_frequency[4] = "6 Hours"
		scrape_frequency[5] = "12 Hours"
		scrape_frequency[6] = "Daily"
		scrape_frequency[7] = "Every 3 Days"
		scrape_frequency[8] = "Weekly"
		scrape_frequency
	end

end

