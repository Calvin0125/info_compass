class Topic < ActiveRecord::Base
  default_scope { order(title: :asc) }  

  after_destroy :destroy_articles, :destroy_search_terms

  has_many :articles
  has_many :search_terms
  belongs_to :user

  validates_presence_of :title, :category
  validates_uniqueness_of :title
  validate on: :create do
    if user && user.topics.length >= 25
      errors.add(:base, message: "You can't have more than 25 topics.")
    end
  end

  def self.add_new_research_articles
    self.where(category: "research").each do |topic|
      topic.add_new_articles
    end
  end
  
  def refresh_new_articles
    # used when a user adds or deletes a search term
    self.articles.where(status: "new").each do |article|
      article.destroy
    end
    self.add_new_articles
  end

  def add_new_articles
    self.user.add_query(self.category)

    if self.category == "research"
      self.add_new_research_articles
    elsif self.category == "news"    
      self.add_new_news_articles
    end
  end

  def add_new_news_articles
    search_terms = self.search_terms.map(&:term)
    return if search_terms == []

    self.get_todays_news_articles_up_to_100(search_terms)
    self.ensure_at_least_25_news_articles(search_terms)
    self.remove_old_news_articles_marked_new
  end

  def get_todays_news_articles_up_to_100(search_terms)
    page = 0
    loop do
      articles = MediaStack.get_one_hundred_articles(search_terms, page)
      articles.each do |article|
        if published_today(article) && unique(article) &&
           self.news_new_today_count < 100 
          article[:topic_id] = self.id
          Article.create(article)
        end
      end

      if articles.length < 100 || !published_today(articles[99]) ||
         self.news_new_today_count >= 100 
        break
      end
      page += 1
    end
  end

  def ensure_at_least_25_news_articles(search_terms)
    page = 0
    while self.articles.where(status: "new").length < 25    
      articles = self.process_next_hundred_news_articles(search_terms, page)
      break if self.articles.where(status: "new").length >= 25 ||
               articles.length < 100
      page += 1
    end
  end

  def remove_old_news_articles_marked_new
    while self.articles.where(status: "new").length > 25 
      article = self.articles.where(status: "new").except(:order).order(date_published: :asc, time_published: :asc).first
      break if published_today(article)
      article.destroy
    end
  end

  def process_next_hundred_news_articles(search_terms, page)
    articles = MediaStack.get_one_hundred_articles(search_terms, page)
      articles.each do |article|
        if unique(article)
          article[:topic_id] = self.id
          Article.create(article)
        end
      end
  end

  def published_today(article)
     article[:date_published] == Date.today.strftime("%F") ||
     article[:date_published] == Date.today
  end

  def news_new_today_count
    return self.articles.where(date_published: Date.today.strftime("%F"), status: "new").length
  end

  def add_new_research_articles
    search_terms = self.search_terms.map(&:term)
    return if search_terms == []

    self.get_todays_research_articles_up_to_50(search_terms)
    self.ensure_at_least_10_research_articles(search_terms)
    # if user did not read or save articles added yesterday
    # they will be replaced by the new articles added today
    self.remove_old_research_articles_marked_new
  end

  def get_todays_research_articles_up_to_50(search_terms)
    page = 0
    loop do
      articles = Arxiv.get_ten_articles(search_terms, page)
      articles.each do |article|
        if published_yesterday(article) && unique(article) &&
           self.research_new_today_count < 50 
          article[:topic_id] = self.id
          Article.create(article)
        end
      end

      if articles.length < 10 || !published_yesterday(articles[9]) ||
         self.research_new_today_count >= 50 
        break
      end
      page += 1
    end
  end

  def ensure_at_least_10_research_articles(search_terms)
    page = 0
    while self.articles.where(status: "new").length < 10    
      articles = self.process_next_ten_research_articles(search_terms, page)
      break if self.articles.where(status: "new").length >= 10 ||
               articles.length < 10
      page += 1
    end
  end

  def remove_old_research_articles_marked_new
    while self.articles.where(status: "new").length > 10
      article = self.articles.where(status: "new").except(:order).order(date_published: :asc).first
      break if published_yesterday(article)
      article.destroy
    end
  end

  def published_yesterday(article)
     article[:date_published] == Date.yesterday.strftime("%F") ||
     article[:date_published] == Date.yesterday
  end

  def unique(article)
    self.articles.where(api: article[:api], url: article[:url]).length == 0
  end

  def process_next_ten_research_articles(search_terms, page)
    articles = Arxiv.get_ten_articles(search_terms, page)
      articles.each do |article|
        if unique(article)
          article[:topic_id] = self.id
          Article.create(article)
        end
      end
  end

  def research_new_today_count
    return self.articles.where(date_published: Date.yesterday.strftime("%F"), status: "new").length
  end

  def destroy_articles
    self.articles.each { |article| article.destroy }
  end

  def destroy_search_terms
    self.search_terms.each { |term| term.destroy }
  end
end
