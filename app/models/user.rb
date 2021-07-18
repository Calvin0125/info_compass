class User < ActiveRecord::Base
  has_secure_password

  has_many :research_topics

  validates_presence_of :username, :email
  validates :password, length: { minimum: 8 }, if: :password_required?
  validates_uniqueness_of :email, :username

  def enforce_password_validation
    @enforce_password_validation = true
  end

  private

  def password_required?
    @enforce_password_validation || password.present?
  end
end
