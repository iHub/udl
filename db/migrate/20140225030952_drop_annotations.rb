class DropAnnotations < ActiveRecord::Migration
  def change
    drop_table :annotations
  end
end
