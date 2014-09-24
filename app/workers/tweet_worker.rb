class TweetWorker
	include Sidekiq::Worker
	sidekiq_options({ queue: :tweets })

	def perform(*args)
		id = args[0]
		term = args[1]
		type = args[2]

		case type
		when "search_api"
			fetch_tweets_from_search_api(term)
		when "fetch"
			fetch_realtime_feed#(term)
		when "follow"
			follow_and_track(id)
		end
	end

	def fetch_realtime_feed #(term)
	  TweetStream.configure do |config|
	    config.consumer_key = ENV['api_key']
	    config.consumer_secret = ENV['api_secret']
	    config.oauth_token = ENV['oauth_token']
	    config.oauth_token_secret = ENV['oauth_secret']
	    config.auth_method = :oauth
	  end

	  @terms = TwitterParser::Term.all.map(&:title)
	  puts "#{@terms.join(', ')}"
	  puts "#{ENV['api_key']} --- #{ENV['api_secret']} ---- #{ENV['oauth_token']} ---- #{ENV['oauth_secret']}"
	  puts ############################################################################################
	  track_tweet_term
	  TweetStream::Client.new.track(@terms.join(', ')) do |status|
	    TwitterParser::Tweet.create_tweet(status)
	  end  
	end

	def follow_and_track(id)
		account = TwitterParser::Account.find(id)
		client = Twitter::REST::Client.new do |config|
		  config.consumer_key = ENV['api_key']
		  config.consumer_secret = ENV['api_secret']
		  config.access_token = ENV['oauth_token']
		  config.access_token_secret = ENV['oauth_secret']
		end

		@twitter_response = client.user("#{account.username}")
		account.create_user_account(@twitter_response) if @twitter_response
		track_tweet_term
	end

	def track_tweet_term
    TweetStream.configure do |config|
      config.consumer_key = ENV['api_key']
      config.consumer_secret = ENV['api_secret']
      config.oauth_token = ENV['oauth_token']
      config.oauth_token_secret = ENV['oauth_secret']
      config.auth_method = :oauth
    end

    @accounts = TwitterParser::Account.all.map(&:twitter_user_id).map(&:to_i)
    TweetStream::Client.new.follow(@accounts) do |status|
      puts "#{status}"
      ###Create an umati term to be included in the terms.
      TwitterParser::Term.create(title: "#{status.text}", channel: "#{status.attrs[:user][:screen_name]}")
      fetch_tweets_from_search_api("#{status.text}")
      # TwitterParser::TweetWorker.perform_async(self.id, "#{status.text}", "search_api")
    end
  end

  def fetch_tweets_from_search_api(term)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['api_key']
      config.consumer_secret = ENV['api_secret']
      config.access_token = ENV['oauth_token']
      config.access_token_secret = ENV['oauth_secret']
    end

    @results = client.search("#{term}", result_type: "recent").take(300)    
    @results.each do |result|
      TwitterParser::Tweet.create_tweet(result)
    end
    fetch_realtime_feed
  end

end