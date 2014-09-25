class CreateTwitterParserTweets < ActiveRecord::Migration
  def change
    create_table :twitter_parser_tweets do |t|
      t.string :tweet_id
      t.string :text
      t.string :tweet_user

      t.timestamps
    end
  end
end
