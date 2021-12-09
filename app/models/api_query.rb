class ApiQuery < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :date, :query_count, :query_type
end
