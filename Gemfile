source 'https://rubygems.org'

gem 'rails',          '4.0.2'
gem 'sass-rails',     '4.0.1'
gem 'uglifier',       '2.1.1'
gem 'coffee-rails',   '4.0.1'
gem 'jquery-rails',   '3.0.4'
gem 'jquery-ui-rails', '4.1.1'
gem 'turbolinks',     '2.2.0'
gem 'jbuilder',       '1.0.2'
gem 'bootstrap-sass', '3.0.3.0'
gem 'sprockets', '~> 2.11.0'
gem 'bcrypt-ruby',    '3.1.2'
gem 'faker',          '1.2.0'
gem 'dalli'
gem 'will_paginate',  '3.0.5'
gem 'bootstrap-will_paginate', '0.0.10'
gem 'koala',          '~> 1.8.0'
gem 'smarter_csv',    '~> 1.0.17'
gem 'ransack',        '~> 1.1.0'
gem 'rake',           '~> 10.1.1'
gem 'delayed_job_web', '1.2.2'
gem 'delayed_job_active_record', '4.0.0'
gem 'roo',            '~> 1.13.2'
gem 'puma'
gem 'pg'
gem 'chosen-rails'
gem 'sinatra'
gem 'pg_search'
gem 'whenever', :require => false
gem 'tweetstream'
gem 'sidekiq'
gem 'figaro', :github=>"laserlemon/figaro"
gem 'twitter_parser', :path => 'lib/twitter_parser'
gem 'tagger', path: 'lib/new-tagger'
gem 'capistrano-sidekiq'
gem "disqus_api"
gem 'sidetiq'
# gem 'net-ssh', '~> 2.8.1'#, :git => "https://github.com/net-ssh/net-ssh"
# gem "disqus_api"

group :development, :test do
  gem 'rspec-rails', '2.14.1'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'capistrano', '~> 2.15.5'
  gem 'rvm-capistrano'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'quiet_assets'
  gem 'thin'
end

group :test do
  gem 'selenium-webdriver', '2.39.0'
  gem 'capybara',           '2.2.1'
  gem 'factory_girl_rails', '4.3.0'
  gem 'cucumber-rails',     '1.4.0', :require => false
  gem 'database_cleaner',   '1.2.0'
end

group :doc do
  gem 'sdoc', '0.4.0', require: false
end

group :production do
  # gem 'pg', '0.15.1'
  ##########Server##########################################################
  gem 'unicorn'
  gem 'unicorn-rails'
  gem 'rails_12factor', '0.0.2'
end