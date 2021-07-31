class ResearchArticle < ActiveRecord::Base
  belongs_to :research_topic
  
  default_scope { order('article_published DESC, title') }

  validates_presence_of :title, :author_csv, :summary, :api, :api_id, :article_published
end
