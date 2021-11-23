require 'rails_helper.rb'

describe Article do
  describe "associations" do
    it { should belong_to(:topic) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author_csv) }
    it { should validate_presence_of(:summary) }
    it { should validate_presence_of(:api) }
    it { should validate_presence_of(:url) }
    it { should validate_presence_of(:date_published) }
  end
 
 describe "order" do
   it "returns articles by date published descending then by title alphabetically" do
     user = Fabricate(:user)
     topic = Fabricate(:topic, user_id: user.id, category: "research")
     article1 = Fabricate(:article, topic_id: topic.id, date_published: Date.yesterday.strftime("%F"), title: "Banana")
     article2 = Fabricate(:article, topic_id: topic.id, date_published: Date.yesterday.strftime("%F"), title: "Apricot", id: 2)
     article3 = Fabricate(:article, topic_id: topic.id, date_published: Date.today.strftime("%F"), title: "Apple", id: 3)
     expect(topic.articles.all.order('date_published DESC, title')).to eq(topic.articles.all)
   end
 end
end
