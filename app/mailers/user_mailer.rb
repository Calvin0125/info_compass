class UserMailer < ApplicationMailer
  default from: 'Info Compass <calvin@infocompass.tech>'

  def reset_password(user, url)
    @user, @url = user, url
    mail to: @user.email, subject: "Reset Your Password"
  end
end
