require 'rails_helper.rb'

describe UsersController do
  describe "GET new" do
    context "no user logged in" do
      it "assigns @user to a new User object" do
        get :new
        expect(assigns(:user)).to be_instance_of(User)
      end
    end

    context "user logged in" do
      it "redirects to users account" do
        login
        get :new
        expect(response).to redirect_to(my_account_path)
      end
    end
  end
end
