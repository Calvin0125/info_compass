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
end
