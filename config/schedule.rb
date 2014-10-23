
set :output, "#{path}/log/cron.log"

set :environment, :production
	every 1.minute do
	  rake "udl:poll"
	end

	# every 5.minutes do
	# 	rake "disqus:fetch"
	# end

  every 10.minutes do
    # runner "ScrapePage.new.collect_comments"
    # runner "ScrapeSession.new.parse_all_sessions"
  end