require 'faraday'
require 'nokogiri'

class Arxiv
  def self.ten_most_recent(search_terms)
    response = self.request(search_terms)
    self.format(response)
  end

  private

  def self.format(response)
    articles = []
    nokogiri_articles = Nokogiri::XML(response.body)
    nokogiri_articles.xpath('//xmlns:entry').each do |entry|
      article = {}
      article[:title] = entry.xpath('.//xmlns:title').text
      article[:authors_csv] = author_csv(entry)
      article[:api] = 'arxiv'
      article[:api_id] = entry.xpath('.//xmlns:id').text
      article[:date_published] = entry.xpath('.//xmlns:published').text[0..9]
      article[:date_updated] = entry.xpath('.//xmlns:updated').text[0..9]
      article[:new] = true
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

  def self.request(search_terms)
    query = self.build_query(search_terms)
    Faraday.get(URI.parse("http://export.arxiv.org/api/query?search_query=#{query}&sortBy=submittedDate&sortOrder=descending"))
  end

  def self.build_query(search_terms)
    query = ''
    search_terms.each.with_index do |term, index|
      if index == 0
        query += "ti:\"#{term}\"ORabs:\"#{term}\""
      else
        query += "ORti:\"#{term}\"ORabs:\"#{term}\""
      end
    end
    query
  end
end 
