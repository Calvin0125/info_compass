class CreateNewsQueries < ActiveRecord::Migration[6.1]
  def change
    create_table :news_queries do |t|
      t.integer :user_id, :query_count
      t.date :date
      t.timestamps
    end
  end
end
