class AddVisitedNewsTopicsToUser < ActiveRecord::Migration[6.1]
  def change
    add_column(:users, :visited_news_topics, :boolean, default: false)
  end
end
