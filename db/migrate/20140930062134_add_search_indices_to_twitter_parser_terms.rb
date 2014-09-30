class AddSearchIndicesToTwitterParserTerms < ActiveRecord::Migration
  def up
  	execute "create index term_title on twitter_parser_terms using gin(to_tsvector('english', title))"
  end

  def down
		execute "drop index term_title"
  end
end
