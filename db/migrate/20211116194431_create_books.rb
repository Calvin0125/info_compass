class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.string :title, :author_csv, :description, :status
      t.date :published_date
      t.integer :author_id
      t.timestamps
    end
  end
end
