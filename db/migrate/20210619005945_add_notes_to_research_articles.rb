class AddNotesToResearchArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :research_articles, :notes, :boolean
  end
end
