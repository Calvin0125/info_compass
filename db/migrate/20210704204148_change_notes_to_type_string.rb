class ChangeNotesToTypeString < ActiveRecord::Migration[6.1]
  def change
    change_column(:research_articles, :notes, :string)
  end
end
