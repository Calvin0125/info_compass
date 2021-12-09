require 'rails_helper.rb'

describe TopicsController do
  describe "GET research_index" do
    context "no user logged in" do
      it_behaves_like "a page that requires login" do
        let(:action) { get :research_index }
      end
    end
    
    context "user logged in" do
      it "sets visited_research_topics to true if user has not visited the page yet" do
        user = Fabricate(:user)
        login(user)
        get :research_index
        user.reload
        expect(user.visited_research_topics).to eq(true)
      end
    end
  end
  
  describe "GET news_index" do
    context "no user logged in" do
      it_behaves_like "a page that requires login" do
        let(:action) { post :news_index }
      end
    end
    
    context "user logged in" do
      it "sets visited_news_topics to true if user has not visited the page yet" do
        user = Fabricate(:user)
        login(user)
        get :news_index
        user.reload
        expect(user.visited_news_topics).to eq(true)
      end
    end
  end

  describe "POST create" do
    context "no user logged in" do
      it_behaves_like "a page that requires login" do
        let(:action) { post :create }
      end
    end

    context "user logged in" do
      before do
        @user = Fabricate(:user)
        login(@user)
        @params = { params: { topic: { title: "Synthetic Biology", category: "research", search_terms: ["synthetic biology", "crispr", "", "", ""] } } }
      end
      
      it "sets the flash warning if there is an error saving the record" do
        post :create, params: { topic: { title: "", category: "research", search_terms: ["hello world", "hello universe", "42", "", ""] } }
        expect(flash[:danger].length).to be > 0
      end

      it "creates the new topic for the logged in user", vcr: { re_record_interval: 7.days } do
        post :create, @params  
        expect(@user.topics.count).to eq(1)
      end

      it "creates the search terms for the new topic", vcr: { re_record_interval: 7.days } do
        post :create, @params
        expect(@user.topics.first.search_terms.count).to eq(2)
      end

      it "adds 10 new articles for the new topic", vcr: { re_record_interval: 7.days } do
        post :create, @params
        expect(@user.topics.first.articles.count).to eq(10)
      end

      it "redirects to research path if category is research", vcr: { re_record_interval: 7.days } do
        post :create, @params
        expect(response).to redirect_to(research_path)
      end

      it "redirects to news path if category is news", vcr: { re_record_interval: 7.days } do
        post :create, params: { topic: { title: "Bitcoin", category: "news", search_terms: ["bitcoin", "", "", "", ""] } }
        expect(response).to redirect_to(news_path)
      end
    end
  end

  describe "DELETE destroy" do
    context "no user logged in" do
      it_behaves_like "a page that requires login" do
        let(:action) { post :create }
      end
    end

    context "user logged in" do
      before do
        @user = Fabricate(:user)
        login(@user)
      end 

      it "deletes the research topic" do
        topic = Fabricate(:topic, user_id: @user.id)
        delete :destroy, params: { id: topic.id }
        expect(Topic.all.count).to eq(0)
      end

      it "doesn't delete the topic if it doesn't belong to the logged in user" do
        topic = Fabricate(:topic, user_id: Fabricate(:user, id: 2).id)
        delete :destroy, params: { id: topic.id }
        expect(Topic.all.count).to eq(1)
      end

      it "redirects to research topics index page" do
        topic = Fabricate(:topic, user_id: @user.id)
        delete :destroy, params: { id: topic.id }
        expect(response).to redirect_to research_path 
      end
    end
  end
end
