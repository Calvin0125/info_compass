require 'rails_helper.rb'

describe User do
  describe "security" do
    it { should have_secure_password }
  end

  describe "associations" do
    it { should have_many(:topics) }
  end

  describe "validations" do
    it { should validate_presence_of :username }
    it { should validate_presence_of :password }
    it { should validate_presence_of :email }
    it { should validate_presence_of :time_zone }
    it { should validate_uniqueness_of :email }
  end

  describe "#set_token" do
    it "should set the token" do
      user = Fabricate(:user)
      user.set_token
      expect(user.reload.token.class).to eq(String)
    end
  end

  describe "#remove_token" do
    it "should remove the token" do
      user = Fabricate(:user, token: SecureRandom.urlsafe_base64)
      user.remove_token
      expect(user.reload.token).to eq(nil)
    end
  end

  describe "#to_param" do
    it "should return the token if it exists" do
      token = SecureRandom.urlsafe_base64
      user = Fabricate(:user, token: token)
      expect(user.to_param).to eq(token)
    end

    it "should return id in string form if no token" do
      user = Fabricate(:user)
      expect(user.to_param).to eq(user.id.to_s)
    end
  end
end
