# config/initializers/koala.rb
# Monkey-patch in Facebook config so Koala knows to 
# automatically use Facebook settings from here if none are given

module Facebook
  FB_CONFIG = YAML.load_file(Rails.root.join("config/facebook.yml"))[Rails.env]
  APP_ID = FB_CONFIG['app_id']
  SECRET = FB_CONFIG['secret_key']
end