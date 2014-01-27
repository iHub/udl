class CreateAppSettings < ActiveRecord::Migration
  def change
    create_table :app_settings do |t|
      t.string :app_name
      t.string :welcome_message
      t.string :fb_app_name
      t.string :fb_app_id
      t.string :fb_app_secret
      t.string :fb_app_access_token
      
      t.timestamps
    end
  end
end
