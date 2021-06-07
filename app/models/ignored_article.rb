class IgnoredArticle < ActiveRecord::Base
  validates_presence_of :api
  validates_uniqueness_of :api_id, scope: :api
end
