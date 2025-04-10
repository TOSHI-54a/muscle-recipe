class Like < ApplicationRecord
  belongs_to :user
  belongs_to :search_recipe
  validates :user_id, uniqueness: { scope: :search_recipe_id }
end
