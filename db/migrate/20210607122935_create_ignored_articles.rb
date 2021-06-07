class CreateIgnoredArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :ignored_articles do |t|
      t.string :api, :api_id
      t.timestamps
    end
  end
end
