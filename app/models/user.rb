class User < ActiveRecord::Base
  has_secure_password

  has_many :topics

  validates_presence_of :username, :email, :time_zone
  validates :password, length: { minimum: 8 }, if: :password_required?
  validates_uniqueness_of :email, :username

  def enforce_password_validation
    @enforce_password_validation = true
  end

  def set_token
    update token: SecureRandom.urlsafe_base64
  end

  def remove_token
    update token: nil 
  end

  def to_param
    token ? token : id.to_s
  end

  private

  def password_required?
    @enforce_password_validation || password.present?
  end
end
