# This migration comes from tagger (originally 20140916121507)
class CreateTaggerAnswers < ActiveRecord::Migration
  def change
    create_table :tagger_answers do |t|
      t.references :question, index: true
      t.string :content

      t.timestamps
    end
  end
end
