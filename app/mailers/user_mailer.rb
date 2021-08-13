class UserMailer < ApplicationMailer
  default from: 'calvin@infocompass.tech'

  def reset_password(user, url)
    @user, @url = user, url
    mail to: @user.email, subject: "Reset Your Password"
  end
end
