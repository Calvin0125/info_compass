require 'rails_helper.rb'

describe SearchTermsController do
  describe "DELETE destroy" do
    it "removes the specified search term", :vcr do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:research_topic, user_id: user.id)
      term = Fabricate(:search_term, research_topic_id: topic.id)     
      delete :destroy, params: { id: term.id.to_s }
      expect(SearchTerm.count).to eq(0)     
    end

    it "only removes the search term if it belongs to the logged in user", :vcr do
      user1 = Fabricate(:user)
      login(user1)
      user2 = Fabricate(:user, id: 2)
      topic = Fabricate(:research_topic, user_id: user2.id)
      term = Fabricate(:search_term, research_topic_id: topic.id)
      delete :destroy, params: { id: term.id.to_s }
      expect(SearchTerm.count).to eq(1)
    end

    it "sets the flash warning if user tries to delete a term for a topic that isn't theirs", :vcr do
      user1 = Fabricate(:user)
      login(user1)
      user2 = Fabricate(:user, id: 2)
      topic = Fabricate(:research_topic, user_id: user2.id)
      term = Fabricate(:search_term, research_topic_id: topic.id)
      delete :destroy, params: { id: term.id.to_s }
      expect(flash[:danger]).to eq("You can only delete search terms for topics that belong to you.")
    end

    it "redirects to the topics index page", :vcr do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:research_topic, user_id: user.id)
      term = Fabricate(:search_term, research_topic_id: topic.id)
      delete :destroy, params: { id: term.id.to_s }
      expect(response).to redirect_to(research_topics_path)
    end

    it "calls #refresh_new_articles on the associated topic", :vcr do
      user = Fabricate(:user)
      login(user)
      topic = Fabricate(:research_topic, user_id: user.id, id: 1)
      term1 = Fabricate(:search_term, research_topic_id: 1, term: 'crispr')
      term2 = Fabricate(:search_term, research_topic_id: 1, id: 2)
      delete :destroy, params: { id: term2.id.to_s }
      expect(ResearchArticle.count).to eq(10)
    end
  end
end
