class AddUserIdToResearchTopic < ActiveRecord::Migration[6.1]
  def change
    add_column(:research_topics, :user_id, :integer)
  end
end
