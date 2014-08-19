set :nginx_certificate_name, -> {"#{fetch(:application)}_ssl" }
set :ssl_only, ask(", is #{fetch(:stage)} ssl only (y/n): ", "n")

namespace :nginx do
  desc "Install the latest stable release of nginx"
  task :install do
    on roles(:web) do
      execute :sudo, "apt-get -y install python-software-properties"
      execute :sudo, "add-apt-repository -y ppa:nginx/stable" #get latest nginx
      execute :sudo, "apt-get -y update" #update apt to nginx
      execute :sudo,  "apt-get -y install nginx"
    end
  end
  after "deploy:install", "nginx:install"

  desc "Setup nginx and its configurations for the application"
  task :setup do
    on roles (:web) do
      execute :sudo, "mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.default" #backup config file
      template "nginx.erb", "/tmp/nginx_confd"
      execute :sudo, "mv /tmp/nginx_confd /etc/nginx/nginx.conf"

      execute :sudo, "rm -f /etc/nginx/sites-enabled/default"
      template "nginx_unicorn.erb", "/tmp/nginx.conf"
      execute :sudo, "mv /tmp/nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}.conf"
      invoke "nginx:restart"
    end
  end
  before "deploy:setup", "nginx:setup"

  desc "Install self signed ssl"
  task :ssl_certs do
    on roles (:web) do
      execute :sudo , "mkdir -p /etc/nginx/certificates"

      template "localhost_crt.erb", "/tmp/localhost.crt"
      execute :sudo, "mv /tmp/localhost.crt /etc/nginx/certificates/#{fetch(:nginx_certificate_name)}.crt"

      template "localhost_key.erb", "/tmp/localhost.key"
      execute :sudo, "mv /tmp/localhost.key /etc/nginx/certificates/#{fetch(:nginx_certificate_name)}.key"
      invoke "nginx:reload"
    end
  end
  before :setup, :ssl_certs


  %w[start stop restart reload].each do |command|
    desc "#{command} nginx"
    task command do
      on roles (:web) do
        execute :sudo, "service nginx #{command}"
      end
    end
  end
  
end