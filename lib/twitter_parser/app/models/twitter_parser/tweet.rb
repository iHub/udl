require 'tweetstream'
require 'twitter'

module TwitterParser
  class Tweet < ActiveRecord::Base
    after_commit :assign_session, on: :create

    default_scope { order('created_at DESC') }

    has_many :tweet_taggers, class_name: "Tagger::TweetTagger"
    belongs_to :scrape_session    
    has_many :tweet_answers
    has_many :answers, :through => :tweet_answers, class_name: "Tagger::Answer"
    has_many :tagger_posts, :class_name => "Tagger::TaggerPost"
    has_many :taggers, :through => :tagger_posts, :foreign_key => "user_id", source: :user
    
    class << self
      def to_csv(tweets)
        CSV.generate do |csv|
          csv << ["Tagged Record", "Tagger", "Session", "Question", "Answer"]
          tweets.each do |tweet|   
            csv << ["#{tweet.text}", "#{tweet.taggers.map(&:username)}", "#{tweet.scrape_session.name}", "#{tweet.answers.first.question.content}", "#{tweet.answers.first.content}"]
          end
        end
      end

      # def follow_and_track
      #   TweetStream.configure do |config|
      #     config.consumer_key = ENV['api_key']
      #     config.consumer_secret = ENV['api_secret']
      #     config.oauth_token = ENV['oauth_token']
      #     config.oauth_token_secret = ENV['oauth_secret']
      #     config.auth_method = :oauth
      #   end

      #   @accounts = TwitterParser::Account.all.map(&:twitter_user_id).map(&:to_i)
      #   TweetStream::Client.new.follow(@accounts) do |status|
      #     puts "#{status}"
      #     TwitterParser::Term.create(title: "#{status.text}", channel: "#{status.attrs[:user][:screen_name]}")
      #     TwitterParser::TweetWorker.perform_async(self.id, "#{status.text}", "search_api")
      #   end
      # end

      def create_tweet(status)
        create(
          :tweet_id => status.id, :text  => status.text, :tweet_created_at => status.created_at, :source => status.source,
          :truncated => status.truncated, :in_reply_to_status_id => status.in_reply_to_status_id, :in_reply_to_user_id => status.in_reply_to_user_id, 
          :in_reply_to_screen_name => status.in_reply_to_screen_name, :tweet_user_id => status.user.id, :tweet_user_name => status.user.name,
          :tweet_user_screen_name => status.user.screen_name,:description => status.user.description,:protected => status.user.protected,
          :followers_count => status.user.followers_count, :friends_count => status.user.friends_count, :listed_count => status.user.listed_count, 
          :tweet_user_created_at => status.user.created_at, :utc_offset => status.user.utc_offset, :time_zone => status.user.time_zone,
          :geo_enabled => status.user.geo_enabled, :verified => status.user.verified, :statuses_count => status.user.statuses_count,
          :contributors_enabled => status.user.contributors_enabled, :is_translator => status.user.is_translator,
          :retweet_count => status.retweet_count, :favorite_count => status.favorite_count, :favorited => status.favorited,
          :retweeted => status.retweeted, :lang => status.lang,
        )
      end
    end

    def assign_session
      AssignSessionWorker.perform_in(1.second, self.id)
    end
  
  end

end
