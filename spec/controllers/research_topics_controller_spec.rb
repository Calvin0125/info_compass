require 'rails_helper.rb'

describe ResearchTopicsController do
  describe "GET index" do
    context "no user logged in" do
      it_behaves_like "a page that requires login" do
        let(:action) { post :create }
      end
    end
    
    context "user logged in" do
      it "sets visited_research_topics to true if user has not visited the page yet" do
        user = Fabricate(:user)
        login(user)
        get :index
        user.reload
        expect(user.visited_research_topics).to eq(true)
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
        @params = { params: { research_topic: { title: "Synthetic Biology", search_terms: ["synthetic biology", "crispr", "", "", ""] } } }
      end
      
      it "sets the flash warning if there is an error saving the record" do
        post :create, params: { research_topic: { title: "", search_terms: ["hello world", "hello universe", "42", "", ""] } }
        expect(flash[:danger].length).to be > 0
      end

      it "creates the new topic for the logged in user", vcr: { re_record_interval: 7.days } do
        post :create, @params  
        expect(@user.research_topics.count).to eq(1)
      end

      it "creates the search terms for the new topic", vcr: { re_record_interval: 7.days } do
        post :create, @params
        expect(@user.research_topics.first.search_terms.count).to eq(2)
      end

      it "adds 10 new articles for the new topic", vcr: { re_record_interval: 7.days } do
        post :create, @params
        expect(@user.research_topics.first.research_articles.count).to eq(10)
      end

      it "redirects to research topics index page", vcr: { re_record_interval: 7.days } do
        post :create, @params
        expect(response).to redirect_to(research_topics_path)
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
        topic = Fabricate(:research_topic, user_id: @user.id)
        delete :destroy, params: { id: topic.id }
        expect(ResearchTopic.all.count).to eq(0)
      end

      it "doesn't delete the topic if it doesn't belong to the logged in user" do
        topic = Fabricate(:research_topic, user_id: Fabricate(:user, id: 2).id)
        delete :destroy, params: { id: topic.id }
        expect(ResearchTopic.all.count).to eq(1)
      end

      it "redirects to research topics index page" do
        topic = Fabricate(:research_topic, user_id: @user.id)
        delete :destroy, params: { id: topic.id }
        expect(response).to redirect_to research_topics_path
      end
    end
  end
end
