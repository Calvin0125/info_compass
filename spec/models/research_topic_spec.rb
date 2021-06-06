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
      5.times { |n| Fabricate(:research_topic, id: n + 1) }
      expect(ResearchTopic.all).to eq(ResearchTopic.order(:title))
    end
  end

  describe "::add_new_articles", :vcr do
    it "loads new articles in database" do
      topic = Fabricate(:research_topic)
      Fabricate(:search_term, research_topic_id: topic.id, term: "artificial intelligence")
      ResearchTopic.add_new_articles
      expect(ResearchArticle.count).to eq(10)
    end
    
    it "loads 10 new articles for each topic" do
      topic1 = Fabricate(:research_topic)
      topic2 = Fabricate(:research_topic, id: 2)
      Fabricate(:search_term, research_topic_id: topic1.id, id: 1, term: "artificial intelligence")
      Fabricate(:search_term, research_topic_id: topic2.id, id: 2, term: "synthetic biology")
      ResearchTopic.add_new_articles
      expect(ResearchArticle.count).to eq(20)
    end

    it "removes oldest articles marked new to ensure only 10 articles marked new in db at once" do
      topic = Fabricate(:research_topic)
      3.times {|n| Fabricate(:research_article, article_published: '2021-01-01', research_topic_id: topic.id, id: n + 1) }
      Fabricate(:search_term, research_topic_id: topic.id, term: "artificial intelligence")
      ResearchTopic.add_new_articles
      expect(ResearchArticle.count).to eq(10)
      expect(ResearchArticle.where(id: 2).length).to eq(0)
    end
  end
end
