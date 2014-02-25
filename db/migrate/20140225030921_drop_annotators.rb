class DropAnnotators < ActiveRecord::Migration
  def change
    drop_table :annotators
  end
end
