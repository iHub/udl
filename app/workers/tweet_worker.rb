class TweetWorker
	include Sidekiq::Worker
	sidekiq_options({ queue: :tweets })

	def perform
	  twitter_configure
	  @terms = TwitterParser::Term.all.map(&:title)
	  puts "#{@terms.join(', ')}"
	  puts "#{ENV['api_key']} --- #{ENV['api_secret']} ---- #{ENV['oauth_token']} ---- #{ENV['oauth_secret']}"
	  TweetStream::Client.new.track(@terms.join(', ')) do |status| 
	  	TwitterParser::Tweet.create_tweet(status)
	  end
	end

	def twitter_configure
		TweetStream.configure do |config|
	    config.consumer_key       = ENV['api_key']
	    config.consumer_secret    = ENV['api_secret']
	    config.oauth_token        = ENV['oauth_token']
	    config.oauth_token_secret = ENV['oauth_secret']
	    config.auth_method        = :oauth
	  end
	end

end