class ChangeArticlesColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :articles, :api_id, :url
    rename_column :articles, :research_topic_id, :topic_id
    add_column :articles, :source, :string
  end
end
