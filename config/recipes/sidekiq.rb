namespace :sidekiq do
  desc "Install upstart"
  task :install, roles: :app do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install upstart"
  end
  after "deploy:install", "sidekiq:install"

  desc 'Generate and upload Upstard configs for daemons needed by the app'
  task :setup, except: {no_release: true} do
    # upstart_config_files = File.expand_path('../upstart/*.conf.erb', __FILE__)
    # upstart_root = '/etc/init'
    # Dir[upstart_config_files].each do |upstart_config_file|
    #   config = ERB.new(IO.read(upstart_config_file)).result(binding)
    #   path = "#{upstart_root}/#{File.basename upstart_config_file, '.erb'}"
    #   put config, path
    # end
    template "sidekiq.conf.erb", "/tmp/sidekiq_conf"
    run "#{sudo} mv /tmp/sidekiq_conf /etc/init/sidekiq.conf"
  end
end
 
after 'deploy:update_code', 'upstart:setup'