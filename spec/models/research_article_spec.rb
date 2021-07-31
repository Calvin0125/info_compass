require 'rails_helper.rb'

describe ResearchArticle do
  describe "associations" do
    it { should belong_to(:research_topic) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author_csv) }
    it { should validate_presence_of(:summary) }
    it { should validate_presence_of(:api) }
    it { should validate_presence_of(:api_id) }
    it { should validate_presence_of(:article_published) }
  end
 
 describe "order" do
   it "returns articles by date published descending then by title alphabetically" do
     user = Fabricate(:user)
     topic = Fabricate(:research_topic, user_id: user.id)
     article1 = Fabricate(:research_article, research_topic_id: topic.id, article_published: Date.yesterday.strftime("%F"), title: "Banana")
     article2 = Fabricate(:research_article, research_topic_id: topic.id, article_published: Date.yesterday.strftime("%F"), title: "Apricot", id: 2)
     article3 = Fabricate(:research_article, research_topic_id: topic.id, article_published: Date.today.strftime("%F"), title: "Apple", id: 3)
     expect(topic.research_articles.all.except(:order).order('article_published DESC, title')).to eq(topic.research_articles.all)
   end
 end
end
