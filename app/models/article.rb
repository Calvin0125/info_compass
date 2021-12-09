class Article < ActiveRecord::Base
  belongs_to :topic
  
  default_scope { order('date_published DESC, time_published DESC, title') }

  validates_presence_of :title, :author_csv, :summary, :api, :url, :date_published

  def pretty_time_published
    return if !self.time_published
    
    time_zone = self.topic.user.time_zone
    self.time_published.in_time_zone(time_zone).strftime("%l:%M %p").strip
  end
end
