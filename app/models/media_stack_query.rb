class MediaStackQuery < ActiveRecord::Base
  validates_presence_of :month, :query_count
end
