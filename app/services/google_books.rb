require 'faraday'
require 'json'
require 'byebug'
class GoogleBooks
  MAX_RESULTS_ALLOWED = 40
  API_KEY = Rails.application.credentials.google_books[:api_key]
  
  def self.get_unique_books(author)
    books = get_all_formatted_results(author)
    return books
  end

  private

  def self.get_all_formatted_results(author)
    start_index = 0
    processed_books = {} 
    total_items_count = get_total_items_count(author)

    while start_index < total_items_count
      books = get_books_from_next_page(author, start_index)
      processed_books = filter_results(books, processed_books, author)
      start_index += MAX_RESULTS_ALLOWED
    end

    processed_books
  end

  def self.get_total_items_count(author)
    response = Faraday.get("https://www.googleapis.com/books/v1/volumes?q=inauthor:#{author}")
    books = JSON.parse(response.body)
    books["totalItems"]
  end

  def self.get_books_from_next_page(author, start_index)
    response = Faraday.get("https://www.googleapis.com/books/v1/volumes?q=inauthor:#{author}&startIndex=#{start_index}&maxResults=#{MAX_RESULTS_ALLOWED}")
    books = JSON.parse(response.body)
    books["items"]
  end

  def self.filter_results(books, processed_books, author)
    books.each do |book|
      if (book["volumeInfo"]["language"] == "en") &&
         (one_author_matches(book["volumeInfo"]["authors"], author))
        title = book["volumeInfo"]["title"]
        published_date = book["volumeInfo"]["publishedDate"]
        authors = book["volumeInfo"]["authors"]
        processed_books[title] = { published_date: published_date, authors: authors }
      end
    end

    processed_books
  end

  def self.one_author_matches(book_authors, author_entered_by_user)
    return false if !book_authors
    book_authors.each do |author|
      return true if author.downcase.gsub(' ', '') == author_entered_by_user.downcase.gsub(' ', '')
    end
    false
  end
end
