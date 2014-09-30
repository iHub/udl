require 'twitter'

module TwitterParser
  class Account < ActiveRecord::Base

  	after_commit :find_user_and_extract_id

  	validates_uniqueness_of :username, on: :create, message: "must be unique"
  	validates_presence_of :username, on: :create, message: "can't be blank"

  	def has_tweet_id?
  		twitter_user_id.present? ? true : false
  	end

  	def find_user_and_extract_id
      AccountWorker.perform_async(self.id, 'follow') if has_tweet_id?.blank?
  	end

  	def create_user_account(twitter_response)
  		name = twitter_response.attrs[:name]
  		twitter_user_id = twitter_response.attrs[:id]
  		@account = Account.find_by_username("#{self.username}")
  		@account.update(name: name, twitter_user_id: twitter_user_id)
  	end

  end
end
