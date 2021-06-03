require 'rails_helper.rb'

describe ResearchArticle do
  describe "associations" do
    it { should belong_to(:research_topic) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author_csv) }
    it { should validate_presence_of(:summary) }
    it { should validate_presence_of(:api) }
    it { should validate_presence_of(:api_id) }
    it { should validate_presence_of(:article_published) }
  end
end
