# A recommended /etc/unicorn/my_app.unicorn.rb

APP_NAME = 'umati' #ENV["APP_NAME"]
APP_ROOT = "/home/deploy/apps/umati/current" #ENV["RAILS_ROOT"]
# RAILS_ENV = ENV["RAILS_ENV"]

pid         "/tmp/unicorn.pid"
listen      "/tmp/unicorn.#{APP_NAME}.sock"
stderr_path "#{APP_ROOT}/log/unicorn_stderr.log"
stdout_path "#{APP_ROOT}/log/unicorn_stdout.log"

working_directory "#{APP_ROOT}"
worker_processes 1
timeout 30