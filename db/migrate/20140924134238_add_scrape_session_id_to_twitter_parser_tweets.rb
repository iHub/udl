class AddScrapeSessionIdToTwitterParserTweets < ActiveRecord::Migration
  def change
    add_reference :twitter_parser_tweets, :scrape_session, index: true
  end
end
