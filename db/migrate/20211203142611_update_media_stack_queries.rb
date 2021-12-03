class UpdateMediaStackQueries < ActiveRecord::Migration[6.1]
  def change
    rename_column(:media_stack_queries, :count, :query_count)
  end
end
