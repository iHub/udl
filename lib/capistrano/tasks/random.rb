	
namespace :random do
	desc "Install Essentials"
	task :colors do
		on roles(:all), in: :groups, limit: 3, wait: 10 do
			execute :sudo, "apt-get -y install curl wget vim less htop"
			execute :sudo, "apt-get -y install imagemagick libmagickwand-dev"
			execute :sudo, %{sed -i -e 's/^#PS1=/PS1=/' /root/.bashrc} # enable the colorful root bash prompt
			# execute :sudo, %{sed -i -e &quot;s/^#alias ll='ls -l'/alias ll='ls -al'/&quot; /root/.bashrc} # enable ll list long alias <3
			info 'Essentials installed'
		end
	end
	after "deploy:install", "random:colors"
end