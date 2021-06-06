class ResearchTopic < ActiveRecord::Base
  default_scope { order(title: :asc) }  

  has_many :research_articles
  has_many :search_terms

  validates_presence_of :title
  
  def self.add_new_articles
    self.all.each do |topic|
      search_terms = topic.search_terms.map(&:term)
      articles = Arxiv.ten_most_recent(search_terms)
      articles.each do |article|
        unless topic.research_articles.where(api: article[:api], api_id: article[:api_id]).length > 0
          article[:research_topic_id] = topic.id
          ResearchArticle.create(article)
        end
      end
      topic.ensure_only_ten_new_articles
    end
  end

  def ensure_only_ten_new_articles
    while self.research_articles.where(new: true).length > 10
      self.research_articles.where(new: true).order(article_published: :asc).first.destroy
    end
  end
end
