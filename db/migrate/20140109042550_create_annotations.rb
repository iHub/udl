class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.integer :user_id
      t.integer :scrape_sessions_id
      t.integer :question_id
      t.integer :answer_id
      t.integer :post_id
      t.timestamps
    end

    add_index  :annotations, :user_id
    add_index  :annotations, :scrape_sessions_id
    add_index  :annotations, :question_id
    add_index  :annotations, :answer_id
    add_index  :annotations, :post_id

  end
end
