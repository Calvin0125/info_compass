class UserMailer < ApplicationMailer
  default from: 'calvin@infocompass.tech'

  def reset_password
    mail to: 'cconley0125@gmail.com', subject: "Testing Testing"
  end
end
