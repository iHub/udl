class CreateDisqusAnswers < ActiveRecord::Migration
  def change
    create_table :disqus_answers do |t|
      t.references :disqus_forum_comment, index: true
      t.references :answer, index: true

      t.timestamps
    end
  end
end
