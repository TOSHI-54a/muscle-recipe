class AddUniqueIndexToLikes < ActiveRecord::Migration[7.2]
  def change
    add_index :likes, [:user_id, :search_recipe_id], unique: true
  end
end
