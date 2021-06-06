class CreateResearchArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :research_articles do |t|
      t.string :title, :author_csv, :summary, :api, :api_id, :research_topic_id
      t.date :article_published, :article_updated
      t.boolean :new, :saved, :read, :not_interested
      t.timestamps
    end
  end
end
