class User < ActiveRecord::Base
  has_secure_password

  has_many :topics
  has_many :api_queries

  validates_presence_of :username, :email, :time_zone
  validates :password, length: { minimum: 8 }, if: :password_required?
  validates_uniqueness_of :email, :username

  def enforce_password_validation
    @enforce_password_validation = true
  end

  def todays_query_count(type)
    date = Time.now.in_time_zone(self.time_zone).strftime("%F")
    if self.api_queries.where(date: date, query_type: type).length == 0
      return 0
    else
      return self.api_queries.where(date: date, query_type: type).first.query_count
    end
  end

  def add_query(type)
    date = Time.now.in_time_zone(self.time_zone).strftime("%F")
 
    if self.todays_query_count(type) == 0
      ApiQuery.create(user_id: self.id, date: date, query_type: type, query_count: 1)
    else
      query_count = self.todays_query_count(type)
      self.api_queries.where(date: date, query_type: type).first.update(query_count: query_count + 1)
    end
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
