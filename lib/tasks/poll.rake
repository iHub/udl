namespace :udl do
	desc "Track account and fetch tweets"
	task :poll => :environment do
		# TweetWorker.perform_async
		AccountWorker.perform_async(nil, "faccount")
		# @account = TwitterParser::Account.first
	 #  AccountWorker.perform_async(@account.id, "follow") if @account
	end
end