class CreateTwitterParserAccounts < ActiveRecord::Migration
  def change
    create_table :twitter_parser_accounts do |t|
      t.string :name
      t.string :twitter_user_id
      t.string :username

      t.timestamps
    end
  end
end
