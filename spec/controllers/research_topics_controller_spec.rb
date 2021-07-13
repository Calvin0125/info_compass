require 'rails_helper.rb'

describe ResearchTopicsController do
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
      
      it "creates the new topic for the logged in user", :vcr do
        post :create, @params  
        expect(@user.research_topics.count).to eq(1)
      end

      it "creates the search terms for the new topic", :vcr do
        post :create, @params
        expect(@user.research_topics.first.search_terms.count).to eq(2)
      end

      it "adds 10 new articles for the new topic", :vcr do
        post :create, @params
        expect(@user.research_topics.first.research_articles.count).to eq(10)
      end

      it "redirects to research topics index page", :vcr do
        post :create, @params
        expect(response).to redirect_to(research_topics_path)
      end
    end
  end
end
