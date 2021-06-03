class CreateSearchTerms < ActiveRecord::Migration[6.1]
  def change
    create_table :search_terms do |t|
      t.string :term
      t.integer :research_topic_id
      t.timestamps
    end
  end
end
