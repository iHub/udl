$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tagger/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tagger"
  s.version     = Tagger::VERSION
  s.authors     = ["Charlie Chuck"]
  s.email       = ["chalcchuck@gmail.com"]
  s.homepage    = ""
  s.summary     = "Tag records/posts using  a set of questions to know the intent of the message/post"
  s.description = "Tag records/posts using  a set of questions to know the intent of the message/post"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.2"
  s.add_dependency "pundit"
  s.add_dependency "rolify"
  s.add_dependency 'jquery-rails'
  s.add_dependency 'chosen-rails'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "pry-doc"
  s.add_development_dependency "puma"
  s.add_development_dependency "faker"
  s.add_development_dependency "quiet_assets"
  s.add_development_dependency "binding_of_caller"
  s.add_development_dependency "better_errors"
  
end
