require 'rails_helper.rb'

describe MediaStackQuery do
  it { should validate_presence_of(:month) }
  it { should validate_presence_of(:query_count) }
end
