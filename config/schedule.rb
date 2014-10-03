
set :output, "#{path}/log/cron.log"

set :environment, :production
	every 30.seconds do
	  rake "udl:poll"
	end

  every 10.minutes do
    # runner "ScrapePage.new.collect_comments"
    # runner "ScrapeSession.new.parse_all_sessions"
  end