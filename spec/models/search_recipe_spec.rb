require 'rails_helper'

RSpec.describe SearchRecipe, type: :model do
    describe "validations" do
        it "queryとsearch_timeがあれば有効" do
            recipe = build(:search_recipe)
            expect(recipe).to be_valid
        end

        it "queryがないと無効" do
            recipe = build(:search_recipe, query: nil)
            expect(recipe).not_to be_valid
        end

        it "search_timeがないと無効" do
            recipe = build(:search_recipe, search_time: nil)
            expect(recipe).not_to be_valid
        end
    end

    describe "関連" do
        it "userに所属していてもしていなくても保存可能(optional)" do
            recipe_with_user = build(:search_recipe, user: create(:user))
            recipe_without_user = build(:search_recipe, user: nil)
            expect(recipe_with_user).to be_valid
            expect(recipe_without_user).to be_valid
        end

        it "likesが関連していて、destroyされると同時に消える" do
            recipe = create(:search_recipe)
            recipe.likes.create!(user: create(:user))
            expect { recipe.destroy }.to change { Like.count }.by(-1)
        end

        it "liked_usersにユーザーが正しく追加される" do
            user = create(:user)
            recipe = create(:search_recipe)
            recipe.likes.create!(user: user)
            expect(recipe.liked_users).to include(user)
        end
    end
end
