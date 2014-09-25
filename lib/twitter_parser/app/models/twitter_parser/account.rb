require 'twitter'

module TwitterParser
  class Account < ActiveRecord::Base

  	after_commit :find_user_and_extract_id

  	validates_uniqueness_of :username, on: :create, message: "must be unique"
  	validates_presence_of :username, :on => :create, :message => "can't be blank"
  	
  # private

  	def has_tweet_id?
  		twitter_user_id.present? ? true : false
  	end

  	def find_user_and_extract_id
      # TweetWorker.perform_async(self.id, nil, 'follow')

  		if has_tweet_id?.blank?
        TweetWorker.perform_async(self.id, nil, 'follow')
	  		# client = Twitter::REST::Client.new do |config|
	  		#   config.consumer_key        = "8LyQJtMQKeXTo5Gn1ljj9afJq"
	  		#   config.consumer_secret     = "rZyvEOMWVIxhWk8hX0GMy2iHiuaIMhMSCQ18TvRX0fdhArg2Xo"
	  		#   config.access_token        = "1157156125-4orIOHxHD3ZiPKQTEmgo70aRPsx09yskPUj5OII"
	  		#   config.access_token_secret = "33dYS6pRGecl0Un1jTKpoHpWWjQl7GaHLTySEJhslYe7B"
	  		# end
	  		# @twitter_response = client.user("#{self.username}")
	  		# create_user_account(@twitter_response) if @twitter_response
	  	end
  	end

  	def create_user_account(twitter_response)
  		name = twitter_response.attrs[:name]
  		twitter_user_id = twitter_response.attrs[:id]
  		@account = Account.find_by_username("#{self.username}")
  		@account.update(name: name, twitter_user_id: twitter_user_id)
  	end

  end
end
