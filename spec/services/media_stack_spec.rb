require 'rails_helper.rb'

describe MediaStack do
  describe "::get_todays_articles", vcr: { re_record_interval: 7.days } do
    it "returns empty array if no results found" do
      articles = MediaStack.get_todays_articles(["apoinwfimdsoihqpsldfjeiwowjfpaosidfj"], 0)
      expect(articles.length).to eq(0)
    end

    it "returns array of hashes that can be used to create a new article after associating them with a topic" do
      articles = MediaStack.get_todays_articles(["metaverse facebook"], 0)
      user = Fabricate(:user)
      articles[0][:topic_id] = Fabricate(:topic, user_id: user.id).id
      Article.create(articles[0])
      expect(Article.count).to eq(1)
    end

    it "logs each request in the media_stack_queries table" do
      MediaStack.get_todays_articles(["metaverse facebook"], 0)
      MediaStack.get_todays_articles(["U.S. president"], 0)
      month = Date.today.strftime("%B")
      expect(MediaStackQuery.where(month: month).first.query_count).to eq(2)
    end
  end
end
