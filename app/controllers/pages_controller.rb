class PagesController < ApplicationController
  before_action :require_no_login

  def index
    render :new_index
  end
end
