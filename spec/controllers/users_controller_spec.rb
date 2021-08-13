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

  describe "GET show" do
    context "no user logged in" do
      it_behaves_like "a page that requires login" do
        let(:action) { get :show }
      end
    end
    
    context "user logged in" do
      before do
        login
      end

      it "sets @user to the current user" do
        get :show
        expect(assigns(:user)).to eq(current_user)
      end

      it "renders show template" do
        get :show
        expect(response).to render_template :show
      end
    end
  end

  describe "GET edit" do
    context "no user logged in" do
      it_behaves_like "a page that requires login" do
        let(:action) { get :edit, params: { id: "1" } }
      end
    end
    
    context "user logged in" do
      before do
        @user = Fabricate(:user)
        login(@user)
      end

      it "sets @user to the current user" do
        get :edit, params: { id: @user.id } 
        expect(assigns(:user)).to eq(current_user)
      end

      it "renders show template" do
        get :edit, params: { id: @user.id }
        expect(response).to render_template :edit
      end
    end
  end

  describe "PUT :update" do
    context "no user logged in" do
      it_behaves_like "a page that requires login" do
        let(:action) { get :edit, params: { id: "1" } }
      end
    end

    context "user logged in" do
      before do
        @user = Fabricate(:user, password: "password")
        login(@user)
      end

      it "updates the attributes for the user" do
        put :update, params: { id: @user.id, user: { username: "Bob123", email: "bob@builder.com", password: "password" } }
        @user.reload
        expect(@user.username).to eq("Bob123")
        expect(@user.email).to eq("bob@builder.com")
      end

      it "doesn't update if the user is not the logged in user" do
        other_user = Fabricate(:user, username: "DonaldDuck123", email: "donald@duck.com", password: "donald123")
        put :update, params: { id: other_user.id, user: { username: "BugsBunny123", email: "bugs@bunny.com", password: "donald123" } }
        expect(other_user.username).to eq("DonaldDuck123")
        expect(other_user.email).to eq("donald@duck.com")
      end

      it "sets the flash warning if the user is not the logged in user" do
        other_user = Fabricate(:user, username: "DonaldDuck123", email: "donald@duck.com", password: "donald123")
        put :update, params: { id: other_user.id, user: { username: "BugsBunny123", email: "bugs@bunny.com", password: "donald123" } }
        expect(flash[:danger]).to eq("You can only edit your own information.")
      end

      it "redirects to my account if the record is valid" do
        put :update, params: { id: @user.id, user: { username: "Bob123", email: "bob@builder.com", password: "password" } }
        expect(response).to redirect_to my_account_path
      end

      it "renders edit template if the record is invalid" do
        put :update, params: { id: @user.id, user: { username: "", email: "", password: "" } }
        expect(response).to render_template :edit
      end

      it "sets the flash success if the record is valid" do
        put :update, params: { id: @user.id, user: { username: "Bob123", email: "bob@builder.com", password: "password" } }
        expect(flash[:success]).to eq("Your account has been updated.")
      end

      it "doesn't update unless the user enters the proper password" do
        old_name = @user.username
        old_email = @user.email
        put :update, params: { id: @user.id, user: { username: "Bob123", email: "bob@builder.com", password: "wrong_password" } }
        @user.reload
        expect(@user.username).to eq(old_name)
        expect(@user.email).to eq(old_email)
      end
    end
  end

  describe "GET forgot_password" do
    context "user logged in" do
      it_behaves_like "a page that requires no login" do
        let(:action) { get :forgot_password }
      end
    end

    context "no user logged in" do
      it "renders forgot password template" do
        get :forgot_password
        expect(response).to render_template :forgot_password 
      end
    end
  end

  describe "POST forgot_password" do
    context "user logged in" do
      it_behaves_like "a page that requires no login" do
        let(:action) { post :forgot_password }
      end
    end

    context "no user logged in" do
      context "valid email" do 
        before(:each) do
          @user = Fabricate(:user)
          post :forgot_password, params: { email: @user.email }
        end

        it "sets the user based on email in params" do
          expect(assigns(:user)).to eq(@user)
        end

        it "sends the email" do
          expect(ActionMailer::Base.deliveries.length).to be > 0
        end

        it "sets a random token on the user requesting a password reset" do
          expect(User.first.token).not_to be_empty
        end

        it "the email contains a link to reset_password/:token" do
          message = ActionMailer::Base.deliveries.last
          expect(message.body).to include("/reset_password/#{@user.reload.token}")
        end

        it "redirects to confirm password reset path" do
          expect(response).to redirect_to reset_password_confirmation_path
        end
      end

      context "invalid email" do
        before(:each) { post :forgot_password, params: { email: Faker::Internet.email } }

        it "redirects to forgot_password" do
          expect(response).to redirect_to forgot_password_path
        end

        it "sets the flash warning" do
          expect(flash[:danger]).to eq("No user matches the email address you entered.")
        end
      end
    end
  end
end
