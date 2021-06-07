require 'rails_helper.rb'

describe IgnoredArticle do
  describe "validations" do
    it { should validate_presence_of(:api) }
    it { should validate_uniqueness_of(:api_id).scoped_to(:api) }
  end
end
