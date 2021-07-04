require 'rails_helper.rb'

describe ResearchArticlesController do
  describe 'POST update' do
    it "updates the status of the article" do
      article = fabricate_research_article(1, "new") 
      login(article.research_topic.user)
      put :update, params: { research_article: { status: "read" }, id: 1 }
      article.reload
      expect(article.status).to eq("read")
    end

    it "only updates the status of the article if it belongs to the logged in user" do
      login(Fabricate(:user, id: 2))
      article = fabricate_research_article(3, "new")
      put :update, params: { research_article: { status: "saved" }, id: 3 }
      article.reload
      expect(article.status).to eq("new")
    end

    it "sets the flash warning if user tries to update an article that is not theirs" do
      login(Fabricate(:user, id: 5))
      article = fabricate_research_article(7, "new")
      put :update, params: { research_article: { status: "saved" }, id: 7 }
      expect(flash[:danger]).to eq("You can only edit articles that belong to you.")
    end

    it "updates the notes on an article" do
      article = fabricate_research_article(8)
      login(article.research_topic.user)
      notes = "These are some important notes about the article."
      put :update, params: { research_article: { notes: notes }, id: 8 }
      article.reload
      expect(article.notes).to eq(notes)
    end

    it "redirects to research topics path" do
      article = fabricate_research_article(9)
      put :update, params: { id: 9 }
      expect(response).to redirect_to research_topics_path
    end
  end
end
