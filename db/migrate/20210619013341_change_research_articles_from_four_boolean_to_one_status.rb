class ChangeResearchArticlesFromFourBooleanToOneStatus < ActiveRecord::Migration[6.1]
  def change
    remove_column :research_articles, :new
    remove_column :research_articles, :saved
    remove_column :research_articles, :read
    remove_column :research_articles, :not_interested
    add_column :research_articles, :status, :string
  end
end
