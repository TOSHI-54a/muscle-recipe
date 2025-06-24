require 'rails_helper'

RSpec.describe "Likes", type: :request do
    let(:user) { create(:user) }
    let(:search_recipe) { create(:search_recipe) }

    before { sign_in user }

    describe "POST /search_recipes/:search_recipe_id/like" do
        it 'お気に入り登録ができる( turbo stream )' do
            expect {
                post search_recipe_like_path(search_recipe), headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }
            }.to change(user.likes, :count).by(1)
            expect(response.body).to include("turbo-stream")
            expect(response.body).to include("action=\"replace\"")
            expect(response.body).to include("target=\"like_button_#{search_recipe.id}\"")
            expect(user.likes.exists?(search_recipe: search_recipe)).to be true
        end
    end

    describe "DELETE /search_recipes/:searach_recipe_id/like" do
        before do
            post search_recipe_like_path(search_recipe),  headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }
        end

        it 'お気に入り解除ができる( turbo stream )' do
            expect {
                delete search_recipe_like_path(search_recipe), headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }
            }.to change(user.likes, :count).by(-1)
            expect(response).to have_http_status(:ok)
            expect(response.body).to include("turbo-stream")
            expect(response.body).to include("action=\"replace\"")
            expect(response.body).to include("target=\"like_button_#{search_recipe.id}\"")
            expect(user.likes.exists?(search_recipe: search_recipe)).to be false
        end
    end
end
