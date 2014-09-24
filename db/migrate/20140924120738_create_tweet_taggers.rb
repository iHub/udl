class CreateTweetTaggers < ActiveRecord::Migration
  def change
    create_table :tweet_taggers do |t|
      t.references :tweet, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
