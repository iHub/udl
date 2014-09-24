# This migration comes from twitter_parser (originally 20140909064017)
class AddFieldsToTwitterParserTweets < ActiveRecord::Migration
  def change
  	 add_column :twitter_parser_tweets, :tweet_created_at, :string
  	 add_column :twitter_parser_tweets, :source, :string
  	 add_column :twitter_parser_tweets, :truncated, :string
  	 add_column :twitter_parser_tweets, :in_reply_to_status_id, :string
  	 add_column :twitter_parser_tweets, :in_reply_to_status_id_str, :string
  	 add_column :twitter_parser_tweets, :in_reply_to_user_id, :string
  	 add_column :twitter_parser_tweets, :in_reply_to_user_id_str, :string
  	 add_column :twitter_parser_tweets, :in_reply_to_screen_name, :string
  	 add_column :twitter_parser_tweets, :user, :string
  	 add_column :twitter_parser_tweets, :tweet_user_id, :string
	   add_column :twitter_parser_tweets, :tweet_user_id_str, :string
	   add_column :twitter_parser_tweets, :tweet_user_name, :string
	   add_column :twitter_parser_tweets, :tweet_user_screen_name, :string
	   add_column :twitter_parser_tweets, :location, :string
	   add_column :twitter_parser_tweets, :url, :string
	   add_column :twitter_parser_tweets, :expanded_url, :string
     add_column :twitter_parser_tweets, :entities_url, :string
     add_column :twitter_parser_tweets, :description, :string
	   add_column :twitter_parser_tweets, :protected, :boolean, default: false
	   add_column :twitter_parser_tweets, :followers_count, :string
	   add_column :twitter_parser_tweets, :friends_count, :string
	   add_column :twitter_parser_tweets, :listed_count, :string
	   add_column :twitter_parser_tweets, :tweet_user_created_at, :string
	   add_column :twitter_parser_tweets, :favourites_count, :string
	   add_column :twitter_parser_tweets, :utc_offset, :string
	   add_column :twitter_parser_tweets, :time_zone, :string
	   add_column :twitter_parser_tweets, :geo_enabled, :boolean, default: false
	   add_column :twitter_parser_tweets, :verified, :boolean, default: false
	   add_column :twitter_parser_tweets, :statuses_count, :string
	   add_column :twitter_parser_tweets, :contributors_enabled, :boolean, default: false
	   add_column :twitter_parser_tweets, :is_translator, :boolean, default: false
	   add_column :twitter_parser_tweets, :is_translation_enabled, :boolean, default: false
	   add_column :twitter_parser_tweets, :following, :string
	   add_column :twitter_parser_tweets, :follow_request_sent, :string
	   add_column :twitter_parser_tweets, :notifications, :string
  	 add_column :twitter_parser_tweets, :geo, :string
  	 add_column :twitter_parser_tweets, :coordinates, :string
  	 add_column :twitter_parser_tweets, :place, :string
  	 add_column :twitter_parser_tweets, :contributors, :string
  	 add_column :twitter_parser_tweets, :retweet_count, :string
  	 add_column :twitter_parser_tweets, :favorite_count, :string
  	 add_column :twitter_parser_tweets, :entities, :string
  	 add_column :twitter_parser_tweets, :hashtags, :string
	   add_column :twitter_parser_tweets, :symbols, :string
	   add_column :twitter_parser_tweets, :urls, :string
	   add_column :twitter_parser_tweets, :user_mentions, :string
  	 add_column :twitter_parser_tweets, :favorited, :boolean, default: false
  	 add_column :twitter_parser_tweets, :retweeted, :boolean, default: false
  	 add_column :twitter_parser_tweets, :possibly_sensitive, :boolean, default: false
  	 add_column :twitter_parser_tweets, :lang, :string
  end
end
