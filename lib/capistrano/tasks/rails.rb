#adding environmental variables
# fetch(:default_env).merge!( secret_key_base: fetch(:secret_key_base) )

set :deploy_secret, ask("Deploy #{fetch(:stage)} Secret Key Base(y/n): ", "n")
set :secret_key_base, proc { `rake secret`.chomp }.call
set :secrets_config, -> {"#{shared_path}/config/secrets.yml"}

namespace :deploy do

	namespace :rails do

		desc "Setup secret key base file in rails app environment"
		task :secrets do 
			on roles :app do
				if fetch(:deploy_secret) == "y"
					execute "mkdir -p #{shared_path}/config"
					template "secrets.yml.erb", '/tmp/secrets_rb'
					execute :sudo, "mv /tmp/secrets_rb #{fetch(:secrets_config)}"
					execute :sudo, "rm #{release_path}/config/secrets.yml"
					execute :sudo, "ln -s #{fetch(:secrets_config)} #{release_path}/config/secrets.yml"
				else
					info "Secret Key is unchanged"
				end
			end
		end
		before "deploy:publishing", "deploy:rails:secrets"

		desc "Generate the database.yml configuration file."
		task :database_yml do
			on roles :app do
				execute :sudo, "rm #{release_path}/config/database.yml"
				template "postgresql.yml.erb", "/tmp/database_yml"
				execute "mkdir -p #{shared_path}/config"
				execute :sudo, "mv /tmp/database_yml", "#{shared_path}/config/database.yml"
				execute :sudo, "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
			end
		end
		before "deploy:updated", "deploy:rails:database_yml"

	end
end