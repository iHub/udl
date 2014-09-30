namespace :postfix do

	desc "Install Postfix loopback only"
	task :install do
		on roles (:all) do
			execute :sudo, 'DEBIAN_FRONTEND=noninteractive apt-get -y install postfix'
		end
	end

	after "deploy:install", "postfix:install"

	desc "Install Postfix loopback only"
	task :setup do
		on roles (:all) do
			execute :sudo, 'bash -c  "echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections"'
			execute :sudo, 'bash -c  "echo "postfix postfix/mailname string localhost" | debconf-set-selections"'
			execute :sudo, 'bash -c  "echo "postfix postfix/destinations string localhost.localdomain, localhost" | debconf-set-selections"'
			execute :sudo, '/usr/sbin/postconf -e "inet_interfaces = loopback-only";'
			execute :sudo, '/usr/sbin/postconf -e "local_transport = error:local delivery is disabled"'
			invoke "postfix:restart"
		end
	end
	after "postfix:install", "postfix:setup"

	%w[start stop restart reload flush check abort force-reload status].each do |command|
		desc "#{command} postfix"
		task command do
			on roles (:all) do
				execute :sudo, "service postfix #{command}"
			end
		end
	end

	desc "Show postfix stats"
	task :stats, roles: :mail do
		run "#{sudo} ls /var/spool/postfix/incoming|wc -l"
		run "#{sudo} ls /var/spool/postfix/active|wc -l"
		run "#{sudo} ls -R /var/spool/postfix/deferred|wc -l"
	end

	desc "Setup postfix configuration for mail server"
	task :setup do
		on roles: :mail do
			set :hostname, find_servers_for_task(current_task).first.host
			template "postfix_main.erb", "/tmp/postfix_main_cf"
			run "#{sudo} mv /etc/postfix/main.cf /tmp/old_postfix_main_cf"
			run "#{sudo} mv /tmp/postfix_main_cf /etc/postfix/main.cf"
			run "#{sudo} /etc/init.d/postfix reload"
		end
	end
end
