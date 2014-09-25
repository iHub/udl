class CreateTaggerQuestions < ActiveRecord::Migration
  def change
    create_table :tagger_questions do |t|
      t.string :content
      t.references :forum, index: true

      t.timestamps
    end
  end
end
