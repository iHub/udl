# This migration comes from tagger (originally 20140918081803)
class CreateTaggerTaggerPosts < ActiveRecord::Migration
  def change
    create_table :tagger_tagger_posts do |t|
      t.references :user, index: true
      t.references :post, index: true

      t.timestamps
    end
  end
end
