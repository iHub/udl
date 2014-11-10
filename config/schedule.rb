set :output, "#{path}/log/cron.log"
set :environment, :production
	
every 1.minute do
  rake "udl:poll"
end

every 5.minutes do
	rake "udl:fetch_disqus"
end