# ActionMailer setup defaults
unless Rails.env == "test"
	ActionMailer::Base.delivery_method = :smtp
	ActionMailer::Base.perform_deliveries = true
	ActionMailer::Base.raise_delivery_errors = false

	# ActionMailer Config
	ActionMailer::Base.smtp_settings = {
	  address: "smtp.mandrillapp.com",
	  port: 587,
	  domain: ENV['host'],
	  user_name: ENV['mandrill_username'],
	  password: ENV['mandrill_password']
	}
end