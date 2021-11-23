class UpdateArticles < ActiveRecord::Migration[6.1]
  def change
    rename_column :articles, :article_published, :date_published
    add_column :articles, :time_published, :time
  end
end
