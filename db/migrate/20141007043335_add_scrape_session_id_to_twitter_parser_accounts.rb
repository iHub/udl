class AddScrapeSessionIdToTwitterParserAccounts < ActiveRecord::Migration
  def change
    add_reference :twitter_parser_accounts, :scrape_session, index: true
  end
end
