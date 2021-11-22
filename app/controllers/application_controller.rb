class ApplicationController < ActionController::Base
  
  auto_session_timeout 1.hour

  def require_login
    if !helpers.logged_in?
      flash[:danger] = "You must be logged in to do that."
      redirect_to login_path 
    end
  end

  def require_no_login
    if helpers.logged_in?
      flash[:warning] = "You are already logged in."
      redirect_to my_account_path
    end
  end
end
