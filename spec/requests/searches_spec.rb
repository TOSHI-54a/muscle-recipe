require 'rails_helper'

RSpec.describe 'Searches', type: :request do
    let(:user) { create(:user) }
    let(:search_recipe) { create(:search_recipe, user: user) }
    before do
        SearchLog.delete_all
        allow_any_instance_of(ChatGptService).to receive(:fetch_recipe).and_return(
            { "recipe" => { "title" => "テストレシピ", "description" => "簡単な説明" } }.to_json # JSON 形式に修正
        )
    end

    describe 'GET /searches/new' do
        it '検索条件入力画面' do
            get new_search_path
            expect(response).to have_http_status(200)
        end
    end

    describe 'POST /searches' do
        let(:valid_params) do
            {
              user: {
                recipe_complexity: "簡単",
                seasonings: "塩, こしょう",
                body_info: { age: 30, gender: "male", height: 175, weight: 70 },
                ingredients: { use: [ "鶏肉", "にんじん" ], avoid: [ "玉ねぎ" ] },
                available: [ { name: "米", amount: "1合" } ],
                preferences: { goal: "筋肉増強", calorie_and_pfc: "500kcal, P:30g, F:10g, C:50g" }
              },
              query: "鶏肉炒め"
            }
        end
        context '検索実行' do
            before { sign_in user }
            it '検索実行' do
                expect {
                    post searches_path, params: valid_params
                }.to change(SearchRecipe, :count).by(1)
                expect(response).to have_http_status(302)
                expect(response).to redirect_to(search_path(SearchRecipe.last))
            end
        end
        context 'ChatGPTから無効なレスポンスを受け取った場合' do
            before do
                allow_any_instance_of(ChatGptService).to receive(:fetch_recipe).and_return(
                    { "recipe" => { "title" => "テストレシピ", "description" => "簡単な説明" } }
                )
            end

            it '新規検索ページをレンダリング' do
                post searches_path, params: valid_params
                expect(response).to have_http_status(302)
            end
        end
    end
    describe 'GET /searches/:id' do
        context '検索結果の詳細ページ' do
            before { sign_in user }

            it '検索結果の表示' do
                get search_path(search_recipe)
                expect(response).to have_http_status(200)
            end
        end
    end
    describe 'GET /searched/saved' do
        context 'ログイン済みの場合' do
            before { sign_in user }
            it '検索履歴の表示' do
                get saved_searches_path
                expect(response).to have_http_status(200)
            end
        end
        context '未ログインの場合' do
            it 'ログインページへリダイレクト' do
                get saved_searches_path
                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_user_session_path)
            end
        end
    end
end
