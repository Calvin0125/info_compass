class CreateMediaStackQueries < ActiveRecord::Migration[6.1]
  def change
    create_table :media_stack_queries do |t|
      t.string :month
      t.integer :count
      t.timestamps
    end
  end
end
