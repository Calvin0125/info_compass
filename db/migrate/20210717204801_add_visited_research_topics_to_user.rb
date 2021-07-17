class AddVisitedResearchTopicsToUser < ActiveRecord::Migration[6.1]
  def change
    add_column(:users, :visited_research_topics, :boolean, default: false)
  end
end
