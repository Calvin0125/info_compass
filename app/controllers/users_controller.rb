class UsersController < ApplicationController
  before_action :require_no_login, only: :new
  before_action :require_login, only: :show

  def new
    @user = User.new
  end

  def show
    
  end
end
