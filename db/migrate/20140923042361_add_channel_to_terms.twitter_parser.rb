# This migration comes from twitter_parser (originally 20140909050233)
class AddChannelToTerms < ActiveRecord::Migration
  def change
    add_column :twitter_parser_terms, :channel, :string
  end
end
