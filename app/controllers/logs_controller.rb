class LogsController < ApplicationController
 #  def index
 #  	path_to_log	= "#{Rails.root}/log/development.log"

 #  	log_file = File.new(path_to_log, "r")
	# if log_file
	#    @log_content = log_file.sysread(1048576)	   
	# else
	#    @log_content = "Unable to access log file!"
	# end
 #  end

	def index
		path_to_log	= "#{Rails.root}/log/development.log"

		log_file = File.open(path_to_log)
		if log_file
		   @log_content = log_file.readlines 
		else
		   @log_content = "Unable to access log file!"
		end
	end

  

end
