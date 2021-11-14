# README

Google Books Explanation
  While playing around with the data, I found the Google Books API to
  have an enormous amount of duplicates, missing metadata, and otherwise
  things that I did not want included on the website. There was not a
  perfect way to filter all of them out, but here is what I did to get 
  highest quality data:
    1. Only retrieve books that have a yyyy-mm-dd format for the date
    2. Only retrieve books that were published in the U.S. in English
    3. Downcase the title to avoid duplicates with different cases and
       pick the title with the oldest publishing date
  Unfortunately there is still a problem with different editions, but
  filtering out books with the word 'edition' would eliminate valid
  books with 'edition' in the title, and filtering out books with
  similar titles but extra words on the end would eliminate a lot
  of valid sequels.


* I will fill out all the stuff for the readme later

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
