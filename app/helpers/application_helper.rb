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

