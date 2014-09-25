module TwitterParser
  module ApplicationHelper
		def format_date(date)
	    date.to_time.strftime("%d-%B-%Y")
	  end

	  def long_date(date)
	    date.to_time.strftime("%d-%B-%Y %H:%M:%S %p")
	  end
  end
end
