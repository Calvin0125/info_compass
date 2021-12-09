class RenameQuery < ActiveRecord::Migration[6.1]
  def change
    rename_table('queries', 'api_queries')
  end
end
