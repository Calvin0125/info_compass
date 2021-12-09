class RenameNewsQueries < ActiveRecord::Migration[6.1]
  def change
    rename_table('news_queries', 'queries')
  end
end
