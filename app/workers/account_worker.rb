class AccountWorker
	include Sidekiq::Worker
	sidekiq_options({ queue: :accounts })
	
	def perform(*args)
		id = args[0]
		type = args[1]

		case type
		when "follow"
			follow_and_track(id)
    when "faccount"
      follow_account
    when "notify"
      notify_user(id)
		end
	end

  def notify_user(id)
    @user = User.find(id)
    NotificationMailer.notify_user(@user).deliver
  end

	def follow_and_track(id)		
    client  = twittter_client_configure		
		account = TwitterParser::Account.find(id)		
		@twitter_response = client.user("#{account.username}")
		account.create_user_account(@twitter_response) if @twitter_response
  end

  def follow_account
    # binding.pry
    tweetstream_configure
    @accounts = TwitterParser::Account.all.map(&:twitter_user_id).join(", ")
    puts "#{@accounts}"
    TweetStream::Client.new.follow(2828013602) do |status|
      # binding.pry
      @screen_name = "#{status.attrs[:user][:screen_name]}"
      @account = TwitterParser::Account.where(username: "#{@screen_name}") if @screen_name
      TwitterParser::Term.create(scrape_session: "#{@account.scrape_session}",title: "#{status.text}", channel: "#{@screen_name}") if @screen_name && @account
      puts "#{status.text}"
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