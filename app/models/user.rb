class User < ActiveRecord::Base
  has_secure_password

  has_many :research_topics

  validates_presence_of :username, :password, :email
  validates_uniqueness_of :email, :username
end
