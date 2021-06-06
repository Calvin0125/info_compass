require 'rails_helper.rb'

describe ResearchTopic do
  describe "associations" do
    it { should have_many(:search_terms) }
    it { should have_many(:research_articles) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
  end

  describe "order" do
    it "returns items alphabetized by topic name" do
      5.times { |n| Fabricate(:research_topic) }
      expect(ResearchTopic.all).to eq(ResearchTopic.order(:title))
    end
  end

  describe "::get_new_articles", :vcr do
    it "test vcr works" do
      articles = ResearchTopic.get_new_articles
      expect(articles.class).to eq(Array)
      expect(articles.length).to eq(10)
    end
  end
end
