require 'faraday'

class MediaStack
  def self.get_todays_articles(search_terms, page)
    response = self.request(search_terms, page)
    self.format(response)
  end

  private

  def self.request(search_terms, page)
    request_url = self.build_request_url(search_terms, page)
    request_url = URI.parse(request_url)
    response = Faraday.get(request_url)
    self.log_request
    response
  end

  def self.build_request_url(search_terms, page)
    access_key = Rails.application.credentials.media_stack[:access_key]
    offset = page * 100
    search_terms = search_terms.join(" ")
    request_url = "http://api.mediastack.com/v1/news?access_key=#{access_key}"
    request_url += "&languages=en&limit=100&sort=published_desc"
    request_url += "&keywords=#{search_terms}"
    request_url += "&offset=#{offset}"
  end

  def self.format(response)
    response = JSON.parse(response.body)
    articles = []
    response["data"].each do |article|
      formatted_article = {}
      formatted_article[:title] = article["title"]
      formatted_article[:author_csv] = get_author(article["author"])
      formatted_article[:summary] = article["description"]
      formatted_article[:url] = article["url"]
      formatted_article[:api] = "media_stack"
      formatted_article[:date_published] = get_date(article["published_at"])
      formatted_article[:time_published] = get_time(article["published_at"])
      formatted_article[:source] = article["source"]
      articles.push(formatted_article)
    end
    articles
  end

  def self.get_author(author)
    author == "" ? "unlisted" : author
  end

  def self.get_date(date_time_string)
    # string format 2020-01-01T05:30:24+00:00
    date_time_string.split("T")[0]
  end

  def self.get_time(date_time_string)
    milliseconds_time = date_time_string.split("T")[1]
    milliseconds_time.split("+")[0]
  end

  def self.log_request
    month = Date.today.strftime("%B")
    if MediaStackQuery.where(month: month).length > 0
      db_entry = MediaStackQuery.where(month: month).first
      query_count = db_entry.query_count
      db_entry.update(query_count: query_count + 1)
    else
      MediaStackQuery.create(month: month, query_count: 1)
    end
  end
end
