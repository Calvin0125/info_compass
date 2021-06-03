require 'rails_helper.rb'

describe SearchTerm do
  describe "associations" do
    it { should belong_to(:research_topic) }
  end
  
  describe "validations" do
    it { should validate_presence_of(:term) }
  end
end
