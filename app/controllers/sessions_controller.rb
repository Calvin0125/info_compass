class SessionsController < ApplicationController
  before_action :require_no_login, only: [:new, :create]
  before_action :require_login, only: :destroy

  auto_session_timeout_actions

  def new
  end

  def create
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:success] = "You have been logged in."
      redirect_to research_topics_path
    else
      flash[:danger] = "Invalid username or password"
      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "You have been logged out."
    redirect_to home_path
  end
end
