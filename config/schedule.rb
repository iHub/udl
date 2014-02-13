
set :output, "#{path}/log/cron.log"

set :environment, :development

    every 10.minutes do
      runner "ScrapeSession.new.parse_all_sessions"
    end