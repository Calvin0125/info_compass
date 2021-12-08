require 'rails_helper.rb'

describe NewsQuery do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :date }
    it { should validate_presence_of :query_count }
  end
end
