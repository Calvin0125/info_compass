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
   it "returns research articles by date published descending then by title alphabetically" do
     user = Fabricate(:user)
     topic = Fabricate(:topic, user_id: user.id, category: "research")
     article1 = Fabricate(:article, topic_id: topic.id, date_published: Date.yesterday.strftime("%F"), title: "Banana")
     article2 = Fabricate(:article, topic_id: topic.id, date_published: Date.yesterday.strftime("%F"), title: "Apricot", id: 2)
     article3 = Fabricate(:article, topic_id: topic.id, date_published: Date.today.strftime("%F"), title: "Apple", id: 3)
     expect(topic.articles.all.order('date_published DESC, title')).to eq(topic.articles.all)
   end

   it "returns news article by date published descending then time published descending then by title alphabetically", vcr: { re_record_interval: 7.days } do
     topic = Fabricate(:topic, user_id: Fabricate(:user).id, category: "news")
     Fabricate(:search_term, topic_id: topic.id, term: "facebook metaverse")
     topic.add_new_news_articles
     expect(topic.articles.all.order('date_published DESC, time_published DESC, title')).to eq(topic.articles.all)
   end
 end

 describe "#pretty_time_published" do
   before :each do
     @user = Fabricate(:user)
     @topic = Fabricate(:topic, user_id: @user.id)
   end

   it "returns nil if there is no time published (ie. for research articles)" do
     article = Fabricate(:article, topic_id: @topic.id)  
     expect(article.pretty_time_published("Mountain Time (US & Canada)")).to eq(nil)
   end

   it "returns pretty time in correct time zone" do
     article = Fabricate(:article, topic_id: @topic.id, time_published: "2021-12-07T21:25:27+00:00")
     # Must use in_time_zone because manually entering the time as a string
     # will cause tests to fail during daylight savings time
     correct_time = Time.parse("21:25 UTC").in_time_zone("Eastern Time (US & Canada)").strftime("%l:%M %p").strip
     expect(article.pretty_time_published("Eastern Time (US & Canada)")).to eq(correct_time)
   end

   it "returns another pretty time in correct time zone" do
     article = Fabricate(:article, topic_id: @topic.id, time_published: "2021-12-07T11:50:35+00:00")
     correct_time = Time.parse("11:50 UTC").in_time_zone("Pacific Time (US & Canada)").strftime("%l:%M %p").strip
     expect(article.pretty_time_published("Pacific Time (US & Canada)")).to eq(correct_time)
   end
 end
end
