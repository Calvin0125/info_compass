class ResearchTopic < ActiveRecord::Base
  default_scope { order(title: :asc) }  

  has_many :research_articles
  has_many :search_terms

  validates_presence_of :title
  validates_uniqueness_of :title
  
  def self.add_new_articles
    self.all.each do |topic|
      search_terms = topic.search_terms.map(&:term)
      page = 0

      # loop ensures that newly published articles always get added, but
      # if there are not enough newly published articles to fill the 'new'
      # section with 10 articles, it will look for older and older articles
      # to find 10 the user hasn't seen before
      loop do
        articles = topic.process_next_ten_articles(search_terms, page)
        break if topic.research_articles.where(new: true).length > 10 || articles.length < 10
        page += 1
      end
      topic.ensure_only_ten_new_articles
    end
  end

  def process_next_ten_articles(search_terms, page)
    articles = Arxiv.get_ten_articles(search_terms, page)
      articles.each do |article|
        unless self.research_articles.where(api: article[:api], api_id: article[:api_id]).length > 0
          article[:research_topic_id] = self.id
          ResearchArticle.create(article)
        end
      end
  end

  def ensure_only_ten_new_articles
    while self.research_articles.where(new: true).length > 10
      self.research_articles.where(new: true).order(article_published: :asc).first.destroy
    end
  end
end
