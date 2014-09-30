#Recipies loaded in alphabetical order
Dir.glob("lib/capistrano/tasks/*.rb").sort.each { |r| load r }

set :application, 'umati'
set :user, 'deploy'

# set :repo_url, "https://github.com/iHub/udl.git"
set :repo_url, "git@github.com:iHub/udl.git"
# set :deploy_to, '/var/www/my_app'
set :deploy_to, "/home/#{fetch(:user)}/#{fetch(:application)}"
# set :port, 6622
set :pty, true
# set :ssh_options, {
  # forward_agent: true
  # port: 6622
# }
set :branch, "develop"
# set :log_level, :info