require 'rails_helper.rb'

describe Arxiv do
  describe "::next_ten" do
    it "returns array of hashes" do
      response = Arxiv.get_ten_articles(["gene editing"])
      expect(response[0].class).to eq(Hash)
    end

    it "doesn't retrieve any ignored id's" do
      
    end
  end
end
