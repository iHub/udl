# This migration comes from twitter_parser (originally 20140818185001)
class CreateTwitterParserTerms < ActiveRecord::Migration
  def change
    create_table :twitter_parser_terms do |t|
      t.string :title

      t.timestamps
    end
  end
end
