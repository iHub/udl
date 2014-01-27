class CreateAnnotators < ActiveRecord::Migration
  def change
    create_table :annotators do |t|
      t.integer :user_id
      t.integer :scrape_sessions_id
      t.string :role

      t.timestamps
    end

    add_index  :annotators, :user_id
    add_index  :annotators, :scrape_sessions_id
  end
end
