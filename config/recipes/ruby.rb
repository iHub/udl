namespace :ruby do
	desc "Install ruby and its all dependancies"
	task :install, roles: :app do
		run "#{sudo} apt-get -y update"
		run "#{sudo} apt-get -y install build-essential openssl libreadline6 libreadline6-dev curl git-core libssl-dev libyaml-dev libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion g++ git"
		run "curl -L https://get.rvm.io | bash -s stable"
		run "source ~/.rvm/scripts/rvm"
    run "rvm install 2.1.0"
    run "gem install bundler --no-ri --no-rdoc"
    run "gem install rake --no-ri --no-rdoc"
	end
	after "deploy:install", "ruby:install"
end