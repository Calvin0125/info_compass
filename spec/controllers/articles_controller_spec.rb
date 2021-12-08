require 'rails_helper.rb'

describe ArticlesController do
  describe 'PUT update' do
    it "updates the status of the article" do
      article = fabricate_research_article(1, "new") 
      login(article.topic.user)
      put :update, params: { article: { status: "read" }, id: 1 }
      article.reload
      expect(article.status).to eq("read")
    end

    it "only updates the status of the article if it belongs to the logged in user" do
      login(Fabricate(:user, id: 2))
      article = fabricate_research_article(3, "new")
      put :update, params: { article: { status: "saved" }, id: 3 }
      article.reload
      expect(article.status).to eq("new")
    end

    it "sets the flash warning if user tries to update an article that is not theirs" do
      login(Fabricate(:user, id: 5))
      article = fabricate_research_article(7, "new")
      put :update, params: { article: { status: "saved" }, id: 7 }
      expect(flash[:danger]).to eq("You can only edit articles that belong to you.")
    end

    it "updates the notes on an article" do
      article = fabricate_research_article(8)
      login(article.topic.user)
      notes = "These are some important notes about the article."
      put :update, params: { article: { notes: notes }, id: 8 }
      article.reload
      expect(article.notes).to eq(notes)
    end

    it "redirects to research topics path" do
      article = fabricate_research_article(9)
      put :update, params: { id: 9 }
      expect(response).to redirect_to research_path
    end
  end

  describe "POST create", vcr: { re_record_interval: 7.days } do
    before :each do
      @user = Fabricate(:user)
      @topic = Fabricate(:topic, category: "news", user_id: @user.id)
      Fabricate(:search_term, term: "facebook metaverse", topic_id: @topic.id)
    end

    it "adds new articles for the topic" do
      post :create, params: { topic_id: @topic.id }
      @topic.reload
      expect(@topic.articles.length).to be >= 25
    end

    it "adds sets user query count of 1 if first query of day" do
      post :create, params: { topic_id: @topic.id }
      @user.reload
      expect(@user.news_queries.where(date: Date.today).first.query_count).to eq(1)
    end
    
    it "adds 1 to user query count" do
      NewsQueries.new(user_id: @user.id, date: Date.today, query_count: 10)
      post :create, params: { topic_id: @topic.id }
      expect(@user.news_queries.where(date: Date.today).first.query_count).to eq(11)
    end

    it "won't let user query news articles more than 25 times" do
      NewsQueries.new(user_id: @user.id, date: Date.today, query_count: 25)
      post :create, params: { topic_id: @topic.id }
      expect(@user.news_queries.where(date: Date.today).first.query_count).to eq(25)
    end

    it "sets the flash warning if user tries to query news articles more than 25 times" do
      NewsQueries.new(user_id: @user.id, date: Date.today, query_count: 25)
      post :create, params: { topic_id: @topic.id }
      expect(flash[:warning]).to eq("You can only request new news articles 25 times per day.")
    end

    it "redirects to news path" do
      post :create, params: { topic_id: @topic.id }
      expect(response).to redirect_to(news_path)
    end
  end
end
