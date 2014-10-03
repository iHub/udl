namespace :redis do
	desc "Install the latest release of Redis on the server"
	task :install, roles: :app do
		run "#{sudo} add-apt-repository -y ppa:chris-lea/redis-server"
		run "#{sudo} apt-get -y update"
		run "#{sudo} apt-get -y install redis-server"
		restart
	end
	after "deploy:install", "redis:install"

	%w[start stop restart].each do |command|
		desc "#{command}ing redis"
		task "#{command}", roles: :web do
			run "#{sudo} service redis-server #{command}"
		end
	end
end