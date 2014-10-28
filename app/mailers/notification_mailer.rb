class NotificationMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.notify_user.subject
  #
  def notify_user(user)
    @user = user
    mail to: @user.email, subject: "Request to Tag Data"
  end
end
