class UsersController < ApplicationController
  before_action :require_no_login, only: [:new, :create]
  before_action :require_login, only: [:show, :edit, :update]

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
    @user = helpers.current_user  
  end

  def edit
    @user = helpers.current_user   
  end

  def update
    @user = User.find(params[:id])
    if @user != helpers.current_user
      flash[:danger] = "You can only edit your own information."
      redirect_to my_account_path
    elsif @user.update(user_params)
      flash[:success] = "Your account has been updated."
      redirect_to my_account_path
    else
      render :edit 
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password)
  end
end
