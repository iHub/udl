def template(from, to, as_root = false)
  template_path = File.expand_path("../../templates/#{from}", __FILE__)
  template = ERB.new(File.new(template_path).read).result(binding)
  upload! StringIO.new(template), to

  sudo "chmod 644 #{to}" # ensure default file chmod
  sudo "chown root:root #{to}" if as_root == true
end

namespace :deploy do

  desc "Install application environment"
  task :install do
    on roles(:all), in: :groups, limit: 3, wait: 10 do
      execute :sudo, "apt-get -y update"
      execute :sudo, "apt-get -y install python-software-properties build-essential zlib1g zlib1g-dev libssl-dev libreadline6 libreadline6-dev openssh-server libyaml-dev libcurl4-openssl-dev libxslt-dev libxml2-dev openssl curl autoconf libc6-dev ncurses-dev automake libtool bison"
      info 'System updated'
    end
  end
  
  desc 'Finish Install'
  task :finish_install do
    on roles(:all), in: :sequence, wait: 5 do
      # TODO Send sms after environment setup is complete. Bring me back from my coffee
      info  '#####################################################################'
      info  '#####################################################################'
      info  'uncomment require "capistrano/rvm" in your Capfile and then '
      info  'run task deploy:setup'
      info  '#####################################################################'
      info  '#####################################################################'
    end
  end
  # after "security:install", "deploy:finish_install" #last task to run is security install

  desc 'Setup environment'
  task :setup do
    on roles(:all), in: :sequence, wait: 5 do
      # Setup postgresql and ruby
      info  '#####################################################################'
      info  '#####################################################################'
      info  'Now remove my repo connection'
      info  '$ git remote rm origin'
      info  'Add your repo. Dont forget to change it in the deploy.rb file too'
      info  '$ git remote add origin https://username@bitbucket.org/'
      info  '$ git push -u origin'
      info  'We are now ready to Deploy >>>>>>>>>>   cap [ENV] deploy '
      info  '$ BITBUCKET_REPO_PASSWORD=yourpassword cap production deploy:install'
      info  '#####################################################################'
      info  '#####################################################################'
    end
  end

  desc 'Restart environment'
  task :restart_env do
    on roles(:all), in: :sequence, wait: 5 do
      # Restart Security
      # Restart mecached 
      # Restart postgresql 
      # Restart Nginx 
      # Restart Redis 
    end
  end

  desc 'Start application'
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc 'Stop application'
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
