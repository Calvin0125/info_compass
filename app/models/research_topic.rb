class ResearchTopic < ActiveRecord::Base
  default_scope { order(title: :asc) }  

  after_destroy :destroy_articles, :destroy_search_terms

  has_many :research_articles
  has_many :search_terms
  belongs_to :user

  validates_presence_of :title
  validates_uniqueness_of :title

  def self.add_new_articles
    self.all.each do |topic|
      topic.add_new_articles
    end
  end
  
  def refresh_new_articles
    self.research_articles.where(status: "new").each do |article|
      article.destroy
    end
    self.add_new_articles
  end
  
  def add_new_articles
    search_terms = self.search_terms.map(&:term)
    page = 0

    # loop ensures that newly published articles always get added, but
    # if there are not enough newly published articles to fill the 'new'
    # section with 10 articles, it will look for older and older articles
    # to find 10 the user hasn't seen before
    loop do
      articles = self.process_next_ten_articles(search_terms, page)
      break if self.research_articles.where(status: "new").length > 10 || articles.length < 10
      page += 1
    end
    self.ensure_only_ten_new_articles
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
    while self.research_articles.where(status: "new").length > 10
      self.research_articles.where(status: "new").except(:order).order(article_published: :asc).first.destroy
    end
  end

  def new_today_count
    return self.research_articles.where(article_published: Date.yesterday.strftime("%F"), status: "new").length
  end

  def destroy_articles
    self.research_articles.each { |article| article.destroy }
  end

  def destroy_search_terms
    self.search_terms.each { |term| term.destroy }
  end
end
