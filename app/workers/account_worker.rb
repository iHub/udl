class AccountWorker
	include Sidekiq::Worker
	sidekiq_options({ queue: :accounts })
	
	def perform(*args)
		id = args[0]
		type = args[1]

		case type
		when "follow"
			follow_and_track(id)
		end
	end

	def follow_and_track(id)
		account = TwitterParser::Account.find(id)
		client  = twittter_client_configure
		@twitter_response = client.user("#{account.username}")
		account.create_user_account(@twitter_response) if @twitter_response
		track_tweet_term
	end

	def track_tweet_term
    tweetstream_configure
    @accounts = TwitterParser::Account.all.map(&:twitter_user_id).map(&:to_i)
    TweetStream::Client.new.follow(@accounts) do |status|
      puts "#{status}"
      TwitterParser::Term.create(title: "#{status.text}", channel: "#{status.attrs[:user][:screen_name]}")
      fetch_tweets_from_search_api("#{status.text}")
    end
  end

  def fetch_tweets_from_search_api(term)
    client = twittter_client_configure
    @results = client.search("#{term}", result_type: "recent").take(300)    
    @results.each { |result| TwitterParser::Tweet.create_tweet(result) }
    TweetWorker.perform_async("fetch")
  end

  def tweetstream_configure
  	TweetStream.configure do |config|
  	  config.consumer_key       = ENV['api_key']
  	  config.consumer_secret    = ENV['api_secret']
  	  config.oauth_token        = ENV['oauth_token']
  	  config.oauth_token_secret = ENV['oauth_secret']
  	  config.auth_method        = :oauth
  	end
  end

  def twittter_client_configure
  	Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['api_key']
      config.consumer_secret     = ENV['api_secret']
      config.access_token        = ENV['oauth_token']
      config.access_token_secret = ENV['oauth_secret']
    end
  end

end