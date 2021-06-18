require 'rails_helper.rb'

describe SessionsController do
  describe "GET new" do
    context "user logged in" do
      it_behaves_like "a page that requires no login" do
        let(:action) { get :new }
      end
    end

    context "no user logged in" do
      it "renders the new template" do
        get :new
        expect(response).to render_template(:new)
      end
    end
  end

  describe "POST new" do
    context "user logged in" do
      it_behaves_like "a page that requires no login" do
        let(:action) { post :new }
      end
    end

    context "no user logged in" do
        before do
          @user = Fabricate(:user)
        end

      context "valid input" do
        it "logs in the user" do
          post :create, params: { username: @user.username, password: @user.password }
          expect(current_user).to eq(@user)
        end

        it "sets the flash notice" do
          post :create, params: { username: @user.username, password: @user.password }
          expect(flash[:success]).to eq("You have been logged in.")
        end

        it "redirects to research topics page" do
          post :create, params: { username: @user.username, password: @user.password }
          expect(response).to redirect_to research_topics_path
        end
      end

      context "invalid input" do
        it "sets the flash notice" do
          post :create, params: { username: @user.username, password: "wrong" }
          expect(flash[:danger]).to eq("Invalid username or password")
        end

        it "redirects to login page" do
          post :create, params: { username: @user.username, password: "wrong" }
          expect(response).to redirect_to login_path
        end
      end
    end
  end
  describe "POST destroy" do
    context "user logged in" do
      before { login }

      it "logs out the user" do
        delete :destroy
        expect(current_user).to eq(nil)
      end

      it "sets the flash notice" do
        delete :destroy
        expect(flash[:success]).to eq("You have been logged out.")
      end
    end

    context "no user logged in" do
      it_behaves_like "a page that requires login" do
        let(:action) { delete :destroy }
      end
    end
  end
end
