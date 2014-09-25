require 'tweetstream'

module TwitterParser
	class Configuration < Struct.new(:consumer_key, :consumer_secret, :oauth_token, :oauth_token_secret, :terms)

		def fetch
			TweetStream.configure do |config|
	      config.consumer_key = consumer_key
	      config.consumer_secret = consumer_secret
	      config.oauth_token = oauth_token
	      config.oauth_token_secret = oauth_token_secret
	      config.auth_method = :oauth
	    end

	    TweetStream::Client.new.track("#{terms}") do |status|
	      puts status
	    end
		end

	end
end