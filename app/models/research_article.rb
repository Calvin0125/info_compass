class ResearchArticle < ActiveRecord::Base
  belongs_to :research_topic

  validates_presence_of :title, :author_csv, :summary, :api, :api_id, :article_published
end
