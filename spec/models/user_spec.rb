require 'rails_helper.rb'

describe User do
  describe "security" do
    it { should have_secure_password }
  end

  describe "associations" do
    it { should have_many(:topics) }
    it { should have_many(:news_queries) }
  end

  describe "validations" do
    it { should validate_presence_of :username }
    it { should validate_presence_of :password }
    it { should validate_presence_of :email }
    it { should validate_presence_of :time_zone }
    it { should validate_uniqueness_of :email }
  end

  describe "#todays_query_count" do
    before :each do
      @user = Fabricate(:user)
    end

    it "should return todays query count" do
      date = Time.now.in_time_zone(@user.time_zone).strftime("%F")
      NewsQuery.create(user_id: @user.id, date: date, query_count: 15)
      expect(@user.todays_news_query_count).to eq(15)
    end

    it "returns zero if no queries yet for today" do
      expect(@user.todays_news_query_count).to eq(0)
    end
  end

  describe "#add_news_query" do
    before :each do
      @user = Fabricate(:user)
    end

    it "if today's date doesn't exist it should create it and set query_count to 1" do
      @user.add_news_query
      expect(@user.todays_news_query_count).to eq(1)
    end

    it "adds one to query count if todays date already exists" do
      NewsQuery.create(user_id: @user.id, date: Date.today, query_count: 12)
      @user.add_news_query
      expect(@user.todays_news_query_count).to eq(13)
    end
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
