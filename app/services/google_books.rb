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
    # Agatha Christie and other prolific authors had < 500 results
    # so 2500 seems like a safe cutoff number
    return too_many_books if total_items_count > 2500

    while start_index < total_items_count
      books = get_books_from_next_page(author, start_index)
      break if !books
      processed_books = filter_results(books, processed_books, author)
      start_index += MAX_RESULTS_ALLOWED
    end

    processed_books_hash_to_array(processed_books)
  end

  def self.get_total_items_count(author)
    response = Faraday.get("https://www.googleapis.com/books/v1/volumes?q=inauthor:#{author}&key=#{API_KEY}")
    books = JSON.parse(response.body)
    books["totalItems"]
  end

  def self.too_many_books
    [{ title: "Error: Too Many Books" }]
  end

  def self.get_books_from_next_page(author, start_index)
    response = Faraday.get("https://www.googleapis.com/books/v1/volumes?q=inauthor:#{author}&startIndex=#{start_index}&maxResults=#{MAX_RESULTS_ALLOWED}&key=#{API_KEY}")
    books = JSON.parse(response.body)
    books["items"]
  end

  def self.filter_results(books, processed_books, author)
    books.each do |book|
      if valid_book(book, processed_books, author)
        # title is downcased to avoid duplicates with different casing
        book = book["volumeInfo"]
        title = book["title"].downcase
        published_date = book["publishedDate"]
        processed_books[title] = { published_date: published_date,
                                   authors: author_csv(book["authors"]),
                                   description: book["description"],
                                   status: get_status(published_date)
                                 }
      end
    end

    processed_books
  end

  def self.valid_book(book, processed_books, author_entered_by_user)
    book["volumeInfo"]["title"] &&
    valid_date(book["volumeInfo"]["publishedDate"]) &&
    oldest_published_date_for_title(book, processed_books) &&
    book["volumeInfo"]["language"] == "en" &&
    book["saleInfo"]["country"] == "US" &&
    one_author_matches(book["volumeInfo"]["authors"], author_entered_by_user)
  end

  def self.valid_date(date)
    /\A\d{4}-\d{2}-\d{2}\Z/.match?(date)
  end

  def self.oldest_published_date_for_title(book, processed_books)
    title = book["volumeInfo"]["title"].downcase
    return true if !processed_books[title]

    already_added_title_date = Date.parse(processed_books[title][:published_date])
    current_title_date = Date.parse(book["volumeInfo"]["publishedDate"])
    current_title_date < already_added_title_date
  end

  def self.one_author_matches(book_authors, author_entered_by_user)
    return false if !book_authors
    book_authors.each do |author|
      return true if author.downcase.gsub(' ', '') == author_entered_by_user.downcase.gsub(' ', '')
    end
    false
  end

  def self.author_csv(authors_array)
    authors_array.join(",")
  end

  def self.get_status(date)
    if Date.parse <= Date.today
      "published"
    else
      "coming_soon"
    end
  end

  def self.processed_books_hash_to_array(processed_books_hash)
    processed_books_array = []

    processed_books_hash.keys.each do |title|
      book = { title: title.titleize, 
               published_date: processed_books_hash[title][:published_date],
               authors: processed_books_hash[title][:authors],
               description: processed_books_hash[title][:description],
               status: processed_books_hash[title][:status]
             }
      processed_books_array.push(book)
    end
    
    processed_books_array
  end
end
