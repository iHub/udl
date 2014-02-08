
set :output, "#{path}/log/cron.log"

set :environment, :development

    every 10.minutes do
      # runner "ScrapePage.new.collect_comments"
      # runner "ScrapeSession.new.parse_all_sessions"
    end