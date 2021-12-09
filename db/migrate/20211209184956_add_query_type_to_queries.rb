class AddQueryTypeToQueries < ActiveRecord::Migration[6.1]
  def change
    add_column(:queries, :query_type, :string)
  end
end
