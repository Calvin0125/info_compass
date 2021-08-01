require 'rails_helper.rb'

describe ResearchTopic do
  describe "associations" do
    it { should have_many(:search_terms) }
    it { should have_many(:research_articles) }
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it "shouldn't allow a user to have more than 25 research topics" do
      user = Fabricate(:user)
      25.times { |n| Fabricate(:research_topic, user_id: user.id, id: n + 1) }
      begin
        Fabricate(:research_topic, user_id: user.id, id: 30)
      rescue
      end
      
      expect(user.reload.research_topics.length).to eq(25)
    end
  end

  describe "after_destroy" do
    it "deletes the associated articles" do 
      topic = Fabricate(:research_topic, user_id: Fabricate(:user).id)
      5.times { |n| Fabricate(:research_article, research_topic_id: topic.id, id: n) }
      topic.destroy
      expect(ResearchArticle.all.count).to eq(0)
    end

    it "deletes the associated search terms" do
      topic = Fabricate(:research_topic, user_id: Fabricate(:user).id)
      5.times { |n| Fabricate(:search_term, research_topic_id: topic.id, id: n) }
      topic.destroy
      expect(SearchTerm.all.count).to eq(0)
    end
  end

  describe "order" do
    it "returns items alphabetized by topic name" do
      5.times { |n| Fabricate(:research_topic, id: n + 1, user_id: Fabricate(:user).id) }
      expect(ResearchTopic.all).to eq(ResearchTopic.order(:title))
    end
  end

  describe "#refresh_new_articles", vcr: { re_record_interval: 7.days } do
    it "removes all the articles currently in new" do
      topic = Fabricate(:research_topic, user_id: Fabricate(:user).id)
      Fabricate(:search_term, term: "crispr", research_topic_id: topic.id)
      articles = []
      5.times do |n| 
        articles << Fabricate(:research_article, id: n, research_topic_id: topic.id)
      end
      topic.refresh_new_articles
      new_articles = topic.research_articles.where(status: "new")
      articles.each { |article| expect(new_articles).not_to include(article) }
    end

    it "adds 10 new articles" do
      topic = Fabricate(:research_topic, user_id: Fabricate(:user).id) 
      Fabricate(:search_term, term: "crispr", research_topic_id: topic.id)
      5.times { |n| Fabricate(:research_article, id: n, research_topic_id: topic.id) }
      topic.refresh_new_articles
      expect(ResearchArticle.count).to eq(10)
    end
  end

  describe "::add_new_articles", vcr: { re_record_interval: 7.days } do
    it "loads new articles in database" do
      topic = Fabricate(:research_topic, user_id: Fabricate(:user).id)
      Fabricate(:search_term, research_topic_id: topic.id, term: "artificial intelligence")
      ResearchTopic.add_new_articles
      expect(ResearchArticle.count).to eq(10)
    end
    
    it "loads 10 new articles for each topic" do
      topic1 = Fabricate(:research_topic, user_id: Fabricate(:user).id)
      topic2 = Fabricate(:research_topic, id: 2, user_id: Fabricate(:user).id)
      Fabricate(:search_term, research_topic_id: topic1.id, id: 1, term: "artificial intelligence")
      Fabricate(:search_term, research_topic_id: topic2.id, id: 2, term: "synthetic biology")
      ResearchTopic.add_new_articles
      expect(ResearchArticle.count).to eq(20)
    end

    it "removes oldest articles marked new to ensure only 10 articles marked new in db at once" do
      topic = Fabricate(:research_topic, user_id: Fabricate(:user).id)
      3.times {|n| Fabricate(:research_article, article_published: '2021-01-01', research_topic_id: topic.id, id: n + 1) }
      Fabricate(:search_term, research_topic_id: topic.id, term: "artificial intelligence")
      ResearchTopic.add_new_articles
      expect(ResearchArticle.count).to eq(10)
      expect(ResearchArticle.where(id: 2).length).to eq(0)
    end

    it "will request multiple pages until there are 10 new articles" do
      topic = Fabricate(:research_topic, user_id: Fabricate(:user).id)
      Fabricate(:research_article, research_topic_id: topic.id, api: 'arxiv', 
      api_id: 'http://arxiv.org/abs/2106.05259v1', status: "read")
      Fabricate(:research_article, research_topic_id: topic.id, api: 'arxiv',
      api_id: 'http://arxiv.org/abs/2106.05228v1', status: "read", id: 2)
      Fabricate(:search_term, research_topic_id: topic.id, term: "black holes")
      ResearchTopic.add_new_articles
      expect(ResearchArticle.count).to eq(12)
    end

    it "won't add the same article twice" do
      topic = Fabricate(:research_topic, user_id: Fabricate(:user).id)
      api_id = 'http://arxiv.org/abs/2106.05259v1'
      Fabricate(:research_article, research_topic_id: topic.id, api: 'arxiv', 
      api_id: api_id, status: "read")
      Fabricate(:search_term, research_topic_id: topic.id, term: "black holes")
      ResearchTopic.add_new_articles
      expect(topic.research_articles.where(api: 'arxiv', api_id: api_id).length).to eq(1) 
    end
  end

  describe "#new_today_count" do
    it "returns the number of articles that are new today(were published yesterday)" do
      user = Fabricate(:user)
      topic = Fabricate(:research_topic, user_id: user.id)
      article1 = Fabricate(:research_article, research_topic_id: topic.id, article_published: Date.yesterday.strftime("%F"))
      article2 = Fabricate(:research_article, research_topic_id: topic.id, article_published: Date.yesterday.strftime("%F"), id: 2)
      article3 = Fabricate(:research_article, research_topic_id: topic.id, article_published: '2021-01-01', id: 3) 
      expect(topic.new_today_count).to eq(2)
    end

    it "doesn't count articles that are saved or read" do
      user = Fabricate(:user)
      topic = Fabricate(:research_topic, user_id: user.id)
      article1 = Fabricate(:research_article, research_topic_id: topic.id, article_published: Date.yesterday.strftime("%F"))
      article2 = Fabricate(:research_article, research_topic_id: topic.id, article_published: Date.yesterday.strftime("%F"), id: 2)
      article3 = Fabricate(:research_article, research_topic_id: topic.id, article_published: '2021-01-01', id: 3) 
      article4 = Fabricate(:research_article, research_topic_id: topic.id, article_published: Date.yesterday.strftime("%F"), status: "read", id: 4)
      article5 = Fabricate(:research_article, research_topic_id: topic.id, article_published: Date.yesterday.strftime("%F"), status: "saved", id: 5)
      expect(topic.new_today_count).to eq(2)
    end
  end
end
