class ApplicationController < ActionController::Base
  def require_login
    if !helpers.logged_in?
      redirect_to root_path
    end
  end

  def require_no_login
    if helpers.logged_in?
      flash[:warning] = "You are already logged in."
      redirect_to my_account_path
    end
  end
end
