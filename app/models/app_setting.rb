class AppSetting < ActiveRecord::Base

    validates :app_name,  presence: true, length: { maximum: 50 }
    validates :fb_app_access_token,   presence: true

end
