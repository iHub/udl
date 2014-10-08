require "bundler/capistrano"
require "rvm/capistrano"
require 'capistrano/sidekiq'
set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

load 'config/recipes/base'
load 'config/recipes/nginx'
load 'config/recipes/unicorn'
load 'config/recipes/redis'
load 'config/recipes/memcached'
load 'config/recipes/check'
load 'config/recipes/assets'
load 'config/recipes/nodejs'
# load 'config/recipes/ruby'

server "41.242.1.68", :web, :app, :db, primary: true

set :rails_env, :production
set :application, "umati"
set :user, "deploy"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :sidekiq_cmd, "bundle exec sidekiq -q tweets, -q accounts, -q sessions"
set :scm, "git"
set :repository, "git@github.com:iHub/udl.git"
set :branch, "develop"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
after "deploy", "deploy:cleanup"