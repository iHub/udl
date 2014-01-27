class CreateScrapeSessions < ActiveRecord::Migration
  def change
    create_table :scrape_sessions do |t|
      t.integer :user_id
      t.string 	:name
      t.text	:description

      t.timestamps
    end

    add_index  :scrape_sessions, :user_id
  end
end
