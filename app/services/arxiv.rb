require 'faraday'
require 'nokogiri'

class Arxiv
  def self.get_ten_articles(search_terms, page)
    response = self.request(search_terms, page)
    self.format(response)
  end

  private

  def self.format(response)
    articles = []
    nokogiri_articles = Nokogiri::XML(response.body)
    nokogiri_articles.xpath('//xmlns:entry').each do |entry|
      article = {}
      article[:title] = entry.xpath('.//xmlns:title').text
      article[:author_csv] = author_csv(entry)
      article[:api] = 'arxiv'
      article[:api_id] = entry.xpath('.//xmlns:id').text
      article[:article_published] = entry.xpath('.//xmlns:published').text[0..9]
      article[:article_updated] = entry.xpath('.//xmlns:updated').text[0..9]
      article[:new] = true
      article[:summary] = entry.xpath('.//xmlns:summary').text || "Summary not available"
      articles.push(article)
    end
    articles
  end

  def self.author_csv(entry)
    author_csv = ''
    entry.xpath('.//xmlns:author').each_with_index do |author, index| 
      if index == 0
        author_csv += author.xpath('./xmlns:name').text
      else
        author_csv += ",#{author.xpath('./xmlns:name').text}"
      end
    end
    author_csv
  end

  def self.request(search_terms, page)
    query = self.build_query(search_terms, page)
    Faraday.get(URI.parse("http://export.arxiv.org/api/query?search_query=#{query}&sortBy=submittedDate&sortOrder=descending"))
  end

  def self.build_query(search_terms, page)
    query = self.build_search_query(search_terms)
    page = page.to_s + '0' if page > 0
    query += "&start=#{page}"
    query
  end

  def self.build_search_query(search_terms)
    query = ''
    search_terms.each.with_index do |term, index|
      if index == 0
        query += "ti:\"#{term}\"+OR+abs:\"#{term}\""
      else
        query += "+OR+ti:\"#{term}\"+OR+abs:\"#{term}\""
      end
    end
    query
  end
end 
