class ResearchTopic < ActiveRecord::Base
  default_scope { order(title: :asc) }  

  has_many :research_articles
  has_many :search_terms

  validates_presence_of :title
  
end
