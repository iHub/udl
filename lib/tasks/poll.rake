namespace :udl do
	desc "Track account and fetch tweets"
	task :poll => :environment do
		TweetWorker.perform_async
		AccountWorker.perform_async(nil, "faccount")
		# @account = TwitterParser::Account.first
	 #  AccountWorker.perform_async(@account.id, "follow") if @account
	end

	desc "Go to Disqus and fetch comments"
	task :fetch_disqus => :environment do
		DisqusWorker.perform_async("nil", "continous")
	end

	desc "dummy tweets"
	task :fake => :environment do
		100.times do
			text = Faker::Lorem.paragraph(2)
			TwitterParser::Tweet.create(text: text, scrape_session: ScrapeSession.first)
		end
	end

	desc "Dummy Disqus"
	task :disqus => :environment do
		100.times do
			text = Faker::Lorem.paragraph(3)
			forum = DisqusForum.first
			DisqusForumComment.create!(disqus_forum: forum, text: text, forum_name: forum.forum_name, scrape_session: ScrapeSession.last)
		end
	end
end