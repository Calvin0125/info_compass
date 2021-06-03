class CreateResearchTopics < ActiveRecord::Migration[6.1]
  def change
    create_table :research_topics do |t|
      t.string :title
      t.timestamps
    end
  end
end
