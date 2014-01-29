
set :output, "#{path}/log/cron.log"

set :environment, :development

    every 10.minutes do
      runner "ScrapePage.new.collect_comments"
    end