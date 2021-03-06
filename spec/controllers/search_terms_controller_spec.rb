require 'rails_helper.rb'

describe SearchTermsController do
  describe "POST create" do
    it "creates the specified search term", vcr: { re_record_interval: 7.days } do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:topic, user_id: user.id)
      post :create, params: { search_term: { term: "crispr", topic_id: topic.id } }
      expect(SearchTerm.count).to eq(1)
    end

    it "sets the flash warning if there is an error with search term" do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:topic, user_id: user.id)
      post :create, params: { search_term: { term: "", topic_id: topic.id } }
      expect(flash[:danger].length).to be > 0
    end

    it "doesn't create the term if it is for a topic that doesn't belong to the logged in user", vcr: { re_record_interval: 7.days } do
      user1 = Fabricate(:user)
      user2 = Fabricate(:user, id: 2)
      login(user1)
      topic = Fabricate(:topic, user_id: user2.id)
      post :create, params: { search_term: { term: "crispr", topic_id: topic.id } }
      expect(SearchTerm.count).to eq(0)
    end
    
    it "sets the flash warning if user tries to add a term for a topic that isn't theirs", vcr: { re_record_interval: 7.days } do
      user1 = Fabricate(:user)
      user2 = Fabricate(:user, id: 2)
      login(user1)
      topic = Fabricate(:topic, user_id: user2.id)
      post :create, params: { search_term: { term: "crispr", topic_id: topic.id } }
      expect(flash[:danger]).to eq("You can only add search terms to topics that belong to you.") 
    end

    it "sets the flash warning if a user has used up their search queries for the day", vcr: { re_record_interval: 7.days } do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:topic, user_id: user.id)
      ApiQuery.create(user_id: user.id, date: Date.today, query_type: "research", query_count: 25)
      post :create, params: { search_term: { term: "crispr", topic_id: topic.id } }
      expect(flash[:danger]).to eq("You can only request new articles 25 times per day.")
    end

    it "redirects to research topics index if the category if research", vcr: { re_record_interval: 7.days } do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:topic, user_id: user.id)
      post :create, params: { search_term: { term: "crispr", topic_id: topic.id } }
      expect(response).to redirect_to research_path
    end

    it "redirects to news topics index if the category if news", vcr: { re_record_interval: 7.days } do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:topic, category: "news", user_id: user.id)
      post :create, params: { search_term: { term: "bitcoin", topic_id: topic.id } }
      expect(response).to redirect_to news_path
    end
   
    it "refreshes new articles for the associated topic", vcr: { re_record_interval: 7.days } do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:topic, user_id: user.id)
      post :create, params: { search_term: { term: "crispr", topic_id: topic.id } }
      expect(Article.count).to eq(10)
    end
  end

  describe "DELETE destroy" do
    it "removes the specified search term", vcr: { re_record_interval: 7.days } do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:topic, user_id: user.id)
      term = Fabricate(:search_term, topic_id: topic.id)     
      delete :destroy, params: { id: term.id.to_s }
      expect(SearchTerm.count).to eq(0)     
    end

    it "only removes the search term if it belongs to the logged in user", vcr: { re_record_interval: 7.days } do
      user1 = Fabricate(:user)
      login(user1)
      user2 = Fabricate(:user, id: 2)
      topic = Fabricate(:topic, user_id: user2.id)
      term = Fabricate(:search_term, topic_id: topic.id)
      delete :destroy, params: { id: term.id.to_s }
      expect(SearchTerm.count).to eq(1)
    end

    it "sets the flash warning if user tries to delete a term for a topic that isn't theirs", vcr: { re_record_interval: 7.days } do
      user1 = Fabricate(:user)
      login(user1)
      user2 = Fabricate(:user, id: 2)
      topic = Fabricate(:topic, user_id: user2.id)
      term = Fabricate(:search_term, topic_id: topic.id)
      delete :destroy, params: { id: term.id.to_s }
      expect(flash[:danger]).to eq("You can only delete search terms for topics that belong to you.")
    end

    it "sets the flash warning if a user has used up their search queries for the day", vcr: { re_record_interval: 7.days } do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:topic, user_id: user.id)
      term = Fabricate(:search_term, topic_id: topic.id)
      ApiQuery.create(user_id: user.id, date: Date.today, query_type: "research", query_count: 25)
      delete :destroy, params: { id: term.id.to_s }
      expect(flash[:danger]).to eq("You can only request new articles 25 times per day.")
    end

    it "redirects to the research page if category is research", vcr: { re_record_interval: 7.days } do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:topic, user_id: user.id)
      term = Fabricate(:search_term, topic_id: topic.id)
      delete :destroy, params: { id: term.id.to_s }
      expect(response).to redirect_to(research_path)
    end

    it "redirects to the news page if category is news", vcr: { re_record_interval: 7.days } do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:topic, category: "news", user_id: user.id)
      term = Fabricate(:search_term, topic_id: topic.id)
      delete :destroy, params: { id: term.id.to_s }
      expect(response).to redirect_to(news_path)
    end

    it "refreshes new articles on the associated topic", vcr: { re_record_interval: 7.days } do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:topic, user_id: user.id, id: 1)
      term1 = Fabricate(:search_term, topic_id: 1, term: 'crispr')
      term2 = Fabricate(:search_term, topic_id: 1, id: 2)
      delete :destroy, params: { id: term2.id.to_s }
      expect(Article.count).to eq(10)
    end
  end
end
