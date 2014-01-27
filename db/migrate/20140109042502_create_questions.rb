class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :scrape_sessions_id
      t.string :question
      t.text :description

      t.timestamps
    end

    add_index  :questions, :scrape_sessions_id
  end
end
