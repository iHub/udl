
set :rvm_ruby_version, '2.1.0'
# set :rvm_type, :user

namespace :ruby do
	desc "Install RVM and Ruby"
	task :install do
		on roles(:app) do
			execute :sudo , %{\\curl -sSL https://get.rvm.io | bash -s stable --ruby=#{fetch(:rvm_ruby_version)}}
			# info "RVM and Ruby Installed"
			execute :sudo, 'echo "source /home/deploy/.rvm/scripts/rvm" > /tmp/rvm-source.sh'
			execute ". /tmp/rvm-source.sh"
		end
	end
	after "deploy:install", "ruby:install"

	desc "Set up Ruby"
	task :setup do
		on roles(:app) do
			execute :sudo , %{bash -c "echo "RAILS_ENV="#{fetch(:rails_env) || fetch(:stage)}"" >> /etc/environment"}
			execute :sudo , %{bash -c "echo "RACK_ENV="#{fetch(:rails_env) || fetch(:stage)}"" >> /etc/environment"}

			# Info "Environment File set up"
			template "gemrc.erb", "/tmp/gemrc"
      execute :sudo, 'bash -c "cat /tmp/gemrc >> ~/.gemrc"'
      execute :sudo, 'bash -c "cat /tmp/gemrc >> /home/deploy/.gemrc"'
			info "Gem Default for production server"

			# execute 'rvm rvmrc trust "/home/deploy/"' #{fetch(:release_path)}'
			execute :sudo , 'bash -c "echo "rvm_trust_rvmrcs_flag=1" >> /home/deploy/.rvmrc"'
			# info "Auto-trust your .rvmrc project files"

		end
	end
	after "ruby:install","ruby:setup"

	desc "update gems and install bundler"
	task :update do
		on roles(:app) do
			# make sure capistrano/rvm is included
			execute :rvm, fetch(:rvm_ruby_version) , :do , "ruby -v"
			execute :rvm, fetch(:rvm_ruby_version) , :do , 'gem update --system'
			execute :rvm, fetch(:rvm_ruby_version) , :do , "gem install bundler --no-ri --no-rdoc"
			info "Ruby Gems updated"
		end
	end
	before "deploy:setup","ruby:update"

end