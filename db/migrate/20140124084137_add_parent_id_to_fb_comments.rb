class AddParentIdToFbComments < ActiveRecord::Migration
  def change
    add_column :fb_comments, :parent_id, :string
  end
end
