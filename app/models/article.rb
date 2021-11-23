class Article < ActiveRecord::Base
  belongs_to :topic
  
  default_scope { order('date_published DESC, title') }

  validates_presence_of :title, :author_csv, :summary, :api, :url, :date_published
end
