class RenameResearchTopicsToTopics < ActiveRecord::Migration[6.1]
  def change
    rename_table 'research_topics', 'topics'
  end
end
