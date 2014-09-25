class CreateTwitterParserTerms < ActiveRecord::Migration
  def change
    create_table :twitter_parser_terms do |t|
      t.string :title

      t.timestamps
    end
  end
end
