set :unicorn_user, -> { fetch(:user) }
set :unicorn_pid, -> { "#{current_path}/tmp/unicorn.pid" }
set :unicorn_config, -> {"#{shared_path}/config/unicorn.rb"}
set :unicorn_log_std, -> { "#{release_path}/log/unicorn.std.log" }
set :unicorn_log_err, -> { "#{release_path}/log/unicorn.err.log" }
set :unicorn_workers, 1

namespace :unicorn do
  desc "Setup Unicorn initializer and app configuration"
  task :setup do 
    on roles :app do
      execute "mkdir -p #{shared_path}/config"
      template "unicorn.rb.erb", '/tmp/unicorn_rb'
      execute :sudo, "mv /tmp/unicorn_rb #{fetch(:unicorn_config)}"
      execute :sudo, "rm #{release_path}/config/unicorn.rb"
      execute :sudo, "ln -s #{fetch(:unicorn_config)} #{release_path}/config/unicorn.rb"

      template "unicorn_init.erb", "/tmp/unicorn_init"
      execute :sudo, "chmod +x /tmp/unicorn_init"
      execute :sudo, "mv /tmp/unicorn_init /etc/init.d/unicorn_#{fetch(:application)}"
      execute :sudo, "update-rc.d -f unicorn_#{fetch(:application)} defaults"
    end
  end
  before "deploy:publishing", "unicorn:setup"

  %w[start stop restart].each do |command|
    desc "#{command} unicorn"
    task command do
      on roles :app do
        execute :sudo, "service unicorn_#{fetch(:application)} #{command}"
      end
    end
    after "deploy:#{command}", "unicorn:#{command}"
  end
end
