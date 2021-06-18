require 'rails_helper.rb'

describe Arxiv do
  describe "::get_ten_articles", :vcr do
    it "returns array of hashes" do
      articles = Arxiv.get_ten_articles(["gene editing"], 0)
      expect(articles[0].class).to eq(Hash)
    end
    
    it "returns empty array if no results found" do
      articles = Arxiv.get_ten_articles(["qwefqweqefqwfwew"], 0)
      expect(articles.length).to eq(0)
    end

    it "returns array of hashes that can be used to create a new article after associating them with a topic" do 
      articles = Arxiv.get_ten_articles(["synthetic biology"], 0)
      user = Fabricate(:user)
      articles[0][:research_topic_id] = Fabricate(:research_topic, user_id: user.id).id
      ResearchArticle.create(articles[0])
      expect(ResearchArticle.count).to eq(1)
    end
  end
end
