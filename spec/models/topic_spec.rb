require 'rails_helper.rb'

describe Topic do
  describe "associations" do
    it { should have_many(:search_terms) }
    it { should have_many(:articles) }
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:category) }
    it "shouldn't allow a user to have more than 25 topics" do
      user = Fabricate(:user)
      25.times { |n| Fabricate(:topic, title: "Topic #{n}", user_id: user.id, id: n + 1) }
      begin
        Fabricate(:topic, user_id: user.id, id: 30)
      rescue
      end
      
      expect(user.reload.topics.length).to eq(25)
    end
  end

  describe "after_destroy" do
    it "deletes the associated articles" do 
      topic = Fabricate(:topic, user_id: Fabricate(:user).id)
      5.times { |n| Fabricate(:article, topic_id: topic.id, id: n) }
      topic.destroy
      expect(Article.all.count).to eq(0)
    end

    it "deletes the associated search terms" do
      topic = Fabricate(:topic, user_id: Fabricate(:user).id)
      5.times { |n| Fabricate(:search_term, topic_id: topic.id, id: n) }
      topic.destroy
      expect(SearchTerm.all.count).to eq(0)
    end
  end

  describe "order" do
    it "returns items alphabetized by topic name" do
      5.times { |n| Fabricate(:topic, id: n + 1, user_id: Fabricate(:user).id) }
      expect(Topic.all).to eq(Topic.order(:title))
    end
  end

  describe "#refresh_new_articles", vcr: { re_record_interval: 7.days } do
    it "removes all the articles currently in new" do
      topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "research")
      Fabricate(:search_term, term: "crispr", topic_id: topic.id)
      articles = []
      5.times do |n| 
        articles << Fabricate(:article, id: n, topic_id: topic.id)
      end
      topic.refresh_new_articles
      new_articles = topic.articles.where(status: "new")
      articles.each { |article| expect(new_articles).not_to include(article) }
    end

    it "adds at least 10 new research articles" do
      topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "research") 
      Fabricate(:search_term, term: "crispr", topic_id: topic.id)
      5.times { |n| Fabricate(:article, id: n, topic_id: topic.id) }
      topic.refresh_new_articles
      expect(Article.count).to be >= 10
    end
  end

  describe "#add_new_articles", vcr: { re_record_interval: 7.days } do
    # #add_new_articles just calls #add_new_research_articles or
    # #add_new_news_articles based on self.category and that behavior
    # is already tested. This is just to make sure queries are being 
    # tallied for the user associated with the topic
    
    context "research" do
      it "adds one to query count if first query of the day" do
        topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "research")
        Fabricate(:search_term, topic_id: topic.id, term: "artificial intelligence")
        topic.add_new_articles
        expect(topic.user.todays_query_count("research")).to eq(1)
      end

      it "does not add one to the wrong query type" do
        topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "research")
        Fabricate(:search_term, topic_id: topic.id, term: "artificial intelligence")
        topic.add_new_articles
        expect(topic.user.todays_query_count("news")).to eq(0)
      end

      it "adds one to query count" do
        user = Fabricate(:user)
        date = Time.now.in_time_zone(user.time_zone).strftime("%F")
        ApiQuery.create(user_id: user.id, date: date, query_type: "research", query_count: 15)
        topic = Fabricate(:topic, user_id: user.id, category: "research")
        Fabricate(:search_term, topic_id: topic.id, term: "artificial intelligence")
        topic.add_new_articles
        expect(topic.user.todays_query_count("research")).to eq(16)
      end
    end

    context "news" do
      it "adds one to query count if first query of the day" do
        topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "news")
        Fabricate(:search_term, topic_id: topic.id, term: "bitcoin")
        topic.add_new_articles
        expect(topic.user.todays_query_count("news")).to eq(1)
      end

      it "does not add one to the wrong query type" do
        topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "news")
        Fabricate(:search_term, topic_id: topic.id, term: "bitcoin")
        topic.add_new_articles
        expect(topic.user.todays_query_count("research")).to eq(0)
      end

      it "adds one to query count" do
        user = Fabricate(:user)
        date = Time.now.in_time_zone(user.time_zone).strftime("%F")
        ApiQuery.create(user_id: user.id, date: date, query_type: "news", query_count: 15)
        topic = Fabricate(:topic, user_id: user.id, category: "news")
        Fabricate(:search_term, topic_id: topic.id, term: "bitcoin")
        topic.add_new_articles
        expect(topic.user.todays_query_count("news")).to eq(16)
      end
    end
  end

  describe "#add_new_news_articles", vcr: { re_record_interval: 7.days } do
    it "adds at least 25 new news articles" do
      topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "news")
      Fabricate(:search_term, topic_id: topic.id, term: "facebook metaverse")
      topic.add_new_news_articles
      expect(Article.count).to be >= 25
    end

    it "does not add more than 100 new news articles" do
      topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "news")
      Fabricate(:search_term, topic_id: topic.id, term: "United States president")
      topic.add_new_news_articles
      expect(Article.count).to be <= 100
    end

    it "won't add the same article twice" do
      article = MediaStack.get_one_hundred_articles(["bitcoin"], 0)[0]
      url = article[:url]
      topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "news")
      Fabricate(:search_term, topic_id: topic.id, term: "bitcoin")
      Fabricate(:article, topic_id: topic.id, url: url, api: "media_stack", status: "read")
      topic.add_new_news_articles
      expect(topic.articles.where(url: url).length).to eq(1)
    end

    it "removes oldest articles marked new to ensure at most 100 articles marked new in db at once" do
      topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "news")
      Fabricate(:search_term, topic_id: topic.id, term: "Wall Street")
      3.times { |n| Fabricate(:article, topic_id: topic.id, date_published: '2021-01-01', id: n + 1) }
      topic.add_new_news_articles
      expect(Article.count).to be >= 25
      expect(Article.count).to be <= 100
      expect(topic.articles.where(id: 2).length).to eq(0)
    end
  end

  describe "#news_new_today_count" do
    it "returns number of articles that are new today" do
      topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "news")
      3.times { |n| Fabricate(:article, topic_id: topic.id, date_published: Date.today.strftime("%F"), id: n + 1) }
      Fabricate(:article, topic_id: topic.id, date_published: Date.yesterday.strftime("%F"), id: 4)
      expect(topic.news_new_today_count).to eq(3)
    end

    it "doesn't count articles that are saved or read" do
      topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "news")
      3.times { |n| Fabricate(:article, topic_id: topic.id, date_published: Date.today.strftime("%F"), id: n + 1) }
      Fabricate(:article, topic_id: topic.id, date_published: Date.today.strftime("%F"), status: "read", id: 4)
      Fabricate(:article, topic_id: topic.id, date_published: Date.today.strftime("%F"), status: "saved", id: 5)
      expect(topic.news_new_today_count).to eq(3)
    end
  end

  describe "::add_new_research_articles", vcr: { re_record_interval: 7.days } do
    it "loads new research articles in database" do
      topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "research")
      Fabricate(:search_term, topic_id: topic.id, term: "artificial intelligence")
      Topic.add_new_research_articles
      expect(Article.count).to be >= 10
    end
    
    it "loads at least 10 new articles for each topic" do
      topic1 = Fabricate(:topic, user_id: Fabricate(:user).id, category: "research")
      topic2 = Fabricate(:topic, id: 2, user_id: Fabricate(:user).id, category: "research")
      Fabricate(:search_term, topic_id: topic1.id, id: 1, term: "artificial intelligence")
      Fabricate(:search_term, topic_id: topic2.id, id: 2, term: "synthetic biology")
      Topic.add_new_research_articles
      expect(Article.count).to be >= 20
    end

    it "removes oldest articles marked new to ensure at most 50 articles marked new in db at once" do
      topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "research")
      3.times {|n| Fabricate(:article, date_published: '2021-01-01', topic_id: topic.id, id: n + 1) }
      Fabricate(:search_term, topic_id: topic.id, term: "artificial intelligence")
      Topic.add_new_research_articles
      expect(Article.count).to be >= 10
      expect(Article.count).to be <= 50
      expect(Article.where(id: 2).length).to eq(0)
    end

    it "will request multiple pages until there are at least 10 new articles" do
      topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "research")
      articles = Arxiv.get_ten_articles(["black holes"], 0)
      url0 = articles[0][:url]
      url1 = articles[1][:url]
      Fabricate(:article, topic_id: topic.id, api: 'arxiv', 
      url: url0, status: "read")
      Fabricate(:article, topic_id: topic.id, api: 'arxiv',
      url: url1, status: "read", id: 2)
      Fabricate(:search_term, topic_id: topic.id, term: "black holes")
      Topic.add_new_research_articles
      expect(Article.count).to be >= 12
    end

    it "won't add the same article twice" do
      topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "research")
      article = Arxiv.get_ten_articles(["quantum physics"], 0)[0]
      url = article[:url]
      Fabricate(:article, topic_id: topic.id, api: 'arxiv', 
      url: url, status: "read")
      Fabricate(:search_term, topic_id: topic.id, term: "black holes")
      Topic.add_new_research_articles
      expect(topic.articles.where(api: 'arxiv', url: url).length).to eq(1) 
    end
  end

  describe "#research_new_today_count" do
    it "returns the number of articles that are new today(were published yesterday)" do
      user = Fabricate(:user)
      topic = Fabricate(:topic, user_id: user.id, category: "research")
      article1 = Fabricate(:article, topic_id: topic.id, date_published: Date.yesterday.strftime("%F"))
      article2 = Fabricate(:article, topic_id: topic.id, date_published: Date.yesterday.strftime("%F"), id: 2)
      article3 = Fabricate(:article, topic_id: topic.id, date_published: '2021-01-01', id: 3) 
      expect(topic.research_new_today_count).to eq(2)
    end

    it "doesn't count articles that are saved or read" do
      user = Fabricate(:user)
      topic = Fabricate(:topic, user_id: user.id, category: "research")
      article1 = Fabricate(:article, topic_id: topic.id, date_published: Date.yesterday.strftime("%F"))
      article2 = Fabricate(:article, topic_id: topic.id, date_published: Date.yesterday.strftime("%F"), id: 2)
      article3 = Fabricate(:article, topic_id: topic.id, date_published: '2021-01-01', id: 3) 
      article4 = Fabricate(:article, topic_id: topic.id, date_published: Date.yesterday.strftime("%F"), status: "read", id: 4)
      article5 = Fabricate(:article, topic_id: topic.id, date_published: Date.yesterday.strftime("%F"), status: "saved", id: 5)
      expect(topic.research_new_today_count).to eq(2)
    end
  end
end
