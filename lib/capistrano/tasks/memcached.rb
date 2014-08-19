set :memcached_memory_limit, 128

namespace :memcached do

	desc "Install Memcached"
	task :install do
		on roles (:app) do
			execute :sudo, "apt-get -y update"
			execute :sudo, "apt-get -y install memcached"
		end
	end
	after "deploy:install", "memcached:install"

	desc "Setup Memcached"
	task :setup do
		on roles (:app) do
			template "memcached.erb", "/tmp/memcached.conf"
			execute :sudo, "mv /tmp/memcached.conf /etc/memcached.conf"
		end
		invoke "memcached:restart"
	end
	after "memcached:install", "memcached:setup"

	%w[start stop restart status].each do |command|
		desc "#{command} Memcached"
		task command do
			on roles (:app) do
				execute :sudo, "service memcached #{command}"
			end
		end
	end

end