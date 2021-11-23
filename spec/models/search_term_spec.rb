require 'rails_helper.rb'

describe SearchTerm do
  describe "associations" do
    it { should belong_to(:topic) }
  end
  
  describe "validations" do
    it { should validate_presence_of(:term) }
    it { should validate_uniqueness_of(:term).ignoring_case_sensitivity }
    it "shouldn't allow a topic to have more than 10 search terms" do
      user = Fabricate(:user)
      topic = Fabricate(:topic, user_id: user.id)
      10.times { |n| Fabricate(:search_term, topic_id: topic.id, id: n + 1) }
      begin
        Fabricate(:search_term, topic_id: topic.id, id: 11)
      rescue
      end
      
      expect(topic.reload.search_terms.length).to eq(10)
    end
  end
end
