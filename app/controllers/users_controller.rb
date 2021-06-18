class UsersController < ApplicationController
  before_action :require_no_login, only: [:new, :create]
  before_action :require_login, only: :show

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Your account has been created, please log in."
      redirect_to login_path
    else
      render :new
    end
  end

  def show
    
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password)
  end
end
