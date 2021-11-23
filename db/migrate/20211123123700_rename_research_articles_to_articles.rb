class RenameResearchArticlesToArticles < ActiveRecord::Migration[6.1]
  def change
    rename_table 'research_articles', 'articles'
  end
end
