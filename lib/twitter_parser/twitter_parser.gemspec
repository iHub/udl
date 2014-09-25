$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "twitter_parser/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "twitter_parser"
  s.version     = TwitterParser::VERSION
  s.authors     = ["Charles Chuck"]
  s.email       = ["chalcchuck@gmail.com"]
  s.homepage    = ""
  s.summary     = "Fetch tweets based on terms."
  s.description = "Fetch tweets based on terms."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.2"
  s.add_dependency "twitter", "~> 5.8.0"
  s.add_dependency "tweetstream"
  s.add_dependency "sidekiq"

  s.add_development_dependency 'quiet_assets'
  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'binding_of_caller'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency "sqlite3"
end
