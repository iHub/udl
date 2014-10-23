class CreateDisqusForums < ActiveRecord::Migration
  def change
    create_table :disqus_forums do |t|
      t.references :user, index: true
      t.references :scrape_session, index: true
      t.string :forum_name

      t.timestamps
    end
  end
end
