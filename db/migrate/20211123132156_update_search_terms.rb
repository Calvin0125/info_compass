class UpdateSearchTerms < ActiveRecord::Migration[6.1]
  def change
    rename_column :search_terms, :research_topic_id, :topic_id
  end
end
