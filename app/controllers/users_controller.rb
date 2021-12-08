class UsersController < ApplicationController
  before_action :require_no_login, only: [:new, :create, :forgot_password, :reset_password, :reset_password_confirmation]
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
    elsif !@user.authenticate(params[:user][:password])
      @user.username = params[:user][:username]
      @user.email = params[:user][:email]
      @user.time_zone = params[:user][:time_zone]
      @user.errors.add(:password, "is incorrect.")
      render :edit
    elsif @user.update(user_params)
      flash[:success] = "Your account has been updated."
      redirect_to my_account_path
    else
      render :edit 
    end
  end

  def forgot_password
    if request.get?
      render :forgot_password
    elsif request.post?
      @user = User.find_by(email: params[:email])

      if @user
        @user.set_token
        @url = reset_password_url(@user)
        UserMailer.reset_password(@user, @url).deliver
        redirect_to reset_password_confirmation_path
      else
        flash[:danger] = "No user matches the email address you entered."
        redirect_to forgot_password_path
      end
    end
  end

  def reset_password
    token = params[:token] || params[:user][:token]
    @user = User.find_by(token: token)  

    if request.get?
      render :reset_password
    elsif request.post?
      @user.password = params[:user][:password]
      if @user.save
        @user.remove_token
        flash[:success] = "Your password has been updated, please log in."
        redirect_to login_path
      else
        render :reset_password
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :time_zone, :password)
  end
end
