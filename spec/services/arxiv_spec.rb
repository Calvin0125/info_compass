require 'rails_helper.rb'

describe Arxiv do
  describe "::get_ten_articles", vcr: { re_record_interval: 7.days } do
    it "returns empty array if no results found" do
      articles = Arxiv.get_ten_articles(["qwefqweqefqwfwew"], 0)
      expect(articles.length).to eq(0)
    end

    it "returns array of hashes that can be used to create a new article after associating them with a topic" do 
      articles = Arxiv.get_ten_articles(["synthetic biology"], 0)
      user = Fabricate(:user)
      articles[0][:topic_id] = Fabricate(:topic, user_id: user.id).id
      Article.create(articles[0])
      expect(Article.count).to eq(1)
    end

    it "only makes one request every 3 seconds" do
      time = Time.now
      Arxiv.get_ten_articles(["artificial intelligence"], 0)
      Arxiv.get_ten_articles(["crispr"], 0)
      expect(Time.now - time).to be >= 3
    end
  end
end
