class CreateTweetAnswers < ActiveRecord::Migration
  def change
    create_table :tweet_answers do |t|
      t.references :tweet, index: true
      t.references :answer, index: true

      t.timestamps
    end
  end
end
