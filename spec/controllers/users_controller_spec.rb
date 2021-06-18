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
      it_behaves_like "a page that requires no login" do
        let(:action) { get :new }
      end
    end
  end

  describe "POST create" do
    context "no user logged in" do
      context "valid input" do
        it "creates a new user" do
          post :create, params: { user: Fabricate.attributes_for(:user) }
          expect(User.count).to eq(1)
        end

        it "sets the flash notice" do
          post :create, params: { user: Fabricate.attributes_for(:user) }
          expect(flash[:success]).to eq("Your account has been created, please log in.")
        end

        it "redirects to login page" do
          post :create, params: { user: Fabricate.attributes_for(:user) }
          expect(response).to redirect_to(login_path)
        end
      end
      
      context "invalid input" do
        it "doesn't create the user" do 
          post :create, params: { user: Fabricate.attributes_for(:user, username: '') }
          expect(User.count).to eq(0)
        end

        it "sets the flash notice" do
          post :create, params: { user: Fabricate.attributes_for(:user, username: '') }
        end

        it "redirects to the new user page" do
          post :create, params: { user: Fabricate.attributes_for(:user, username: '') }
          expect(response).to render_template(:new)
        end
      end
    end

    context "user logged in" do
      it_behaves_like "a page that requires no login" do
        let(:action) { post :create }
      end
    end
  end
end
