namespace :security do
	desc "Install firewall and security on the server"
	task :install do
		on roles (:all) do
			execute :sudo ,"apt-get install -y ufw fail2ban logcheck logcheck-database"
		end
	end
	before "security:install","postfix:install"
	after "deploy:install", "security:install"

	desc "Setup security"
	task :setup do
		on roles (:all) do
			execute :sudo, "ufw logging on"
			execute :sudo, "ufw default deny"
			execute :sudo, "ufw allow ssh"
			execute :sudo, "ufw allow http"
			execute :sudo, "ufw allow https"
			execute :sudo, "ufw allow 8088"
			execute :sudo, "ufw allow 8089"
		end
	end
	after "security:install", "security:setup"

	desc "Enable security"
	task :enable do
		on roles (:all) do
			execute "echo 'y' |sudo ufw enable "
			invoke "security:status"
		end
	end
	after :setup, :enable

	 %w[enable status].each do |command|
    desc "#{command} nginx"
    task command do
      on roles (:web) do
        execute :sudo, "echo 'y' |sudo ufw #{command}"
      end
    end
  end

end
  after "security:install", "deploy:finish_install" #last task to run is security install
