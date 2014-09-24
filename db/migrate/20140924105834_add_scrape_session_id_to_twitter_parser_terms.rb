class AddScrapeSessionIdToTwitterParserTerms < ActiveRecord::Migration
  def change
    add_reference :twitter_parser_terms, :scrape_session, index: true
    add_reference :tagger_questions, :scrape_session, index: true
  end
end
