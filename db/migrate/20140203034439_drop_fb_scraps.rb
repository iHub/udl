class DropFbScraps < ActiveRecord::Migration
  def change
    drop_table :fb_scraps
  end
end
