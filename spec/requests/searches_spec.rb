require 'rails_helper'
require 'ostruct'

RSpec.describe 'Searches', type: :request do
    let(:user) { create(:user) }

    before do
        # GPT API通信をモック化
        allow_any_instance_of(ChatGptService).to receive(:fetch_recipe).and_return(
            {
                "recipe" => {
                    "title" => "モックレシピ",
                    "description" => "テスト用の説明",
                    "ingredients" => [
                        { "name " => "卵", "amount" => "2個" }
                    ],
                    "step" => [
                        "混ぜる",
                        "焼く"
                    ],
                    "nutrition" => {
                        "calories" => "300kcal",
                        "protein" => "20g",
                        "fat" => "10g",
                        "carbohydrates" => "30g"
                    }
                }
            }
        )
    end

    describe 'GET /searches/new' do
        it '検索フォームが表示される' do
            sign_in user
            get new_search_path
            expect(response).to have_http_status(:ok)
            expect(response.status).to eq(200)
            expect(response.body).to include("検索")
        end

        it 'ゲストがレシピ検索した場合、表示される（保存なし）' do
            guest_user = User.new
            get new_search_path(guest_user)
            expect(response).to have_http_status(:ok)
        end
    end

    describe 'POST /searche' do
        let(:valid_params) do
            {
                user: {
                    recipe_complexity: "簡単",
                    seasonings: "塩",
                    body_info: { age: 30, gender: "male", height: 170, weight: 65 },
                    ingredients: { use: [ "卵" ], aboid: [] },
                    available: [ { name: "米", amount: "1合" } ],
                    preferences: { goal: "筋肉増強" }
                },
                query: "筋肉飯"
            }
        end

        context 'ログイン済み・正常なリクエスト' do
            before { sign_in user }

            it 'レシピが保存され、リダイレクトされる' do
                expect {
                    post searches_path, params: valid_params
                }.to change(SearchRecipe, :count).by(1)

                expect(response).to have_http_status(:found)
                follow_redirect!
                expect(response.body).to include("モックレシピ")
            end
        end

        context '未ログイン・正常なリクエスト' do
            it 'レシピは保存されず、検索回数が加算され、レシピ詳細にリダイレクトされる' do
                guest_user = User.new
                expect {
                    post searches_path, params: valid_params
                }.not_to change(SearchRecipe, :count)

                expect(response).to have_http_status(:found)
                follow_redirect!
                expect(response.body).to include("モックレシピ")
            end
        end

        context 'ChatGPTがnilを返す場合' do
            before do
                allow_any_instance_of(ChatGptService).to receive(:fetch_recipe).and_return(nil)
                sign_in user
            end

            it '検索結果が表示されず、newが再表示される' do
                post searches_path, params: valid_params
                expect(response).to have_http_status(:unprocessable_entity)
                expect(SearchRecipe.count).to eq(0)
            end

            it '保存されず、フォームに戻る' do
            invalid_params = valid_params.merge(query: "")
            post searches_path, params: invalid_params
            # expect(response).to have_http_status(:ok)
            expect(response.body).to include("レシピの取得に失敗しました。もう一度お試しください")
            end
        end

        context '例外処理' do
            before { sign_in user }
            it '503:API接続失敗時は接続エラーメッセージが表示される' do
                allow_any_instance_of(ChatGptService).to receive(:fetch_recipe).and_raise(Net::OpenTimeout)

                post searches_path, params: valid_params
                expect(response).to have_http_status(:service_unavailable)
                expect(response.body).to include("外部APIに接続できませんでした。")
            end
            it '422:予期しないエラー時はエラーエッセー時が表示される' do
                allow_any_instance_of(ChatGptService).to receive(:fetch_recipe).and_raise(RuntimeError.new("テスト例外"))

                post searches_path, params: valid_params
                expect(response).to have_http_status(:unprocessable_entity)
                expect(response.body).to include("予期しないエラーが発生しました。")
            end
        end

        context '回数制限' do
            before do
                sign_in user
                allow_any_instance_of(SearchesController).to receive(:search_count) do |controller|
                    controller.instance_variable_set(:@search_limit, 0)
                end
            end

            it '検索回数をオーバーするとリダイレクトされる' do
                post searches_path, params: valid_params
                expect(response).to redirect_to saved_searches_path
            end
        end
    end

    describe 'GET /searches/saved' do
        context 'ログイン済み' do
            before { sign_in user }

            it '保存されたレシピ一覧が見られる' do
                get saved_searches_path
                expect(response).to have_http_status(:ok)
                expect(response.body).to include("保存済みレシピ一覧")
            end
        end

        context '未ログイン' do
            it 'ログインページにリダイレクトされる' do
                get saved_searches_path
                expect(response).to redirect_to(new_user_session_path)
            end
        end
    end

    describe 'POST /searches/optimized' do
        context 'ログイン済み' do
            before { sign_in user }

            it 'FastAPIが成功し、レシピ詳細にリダイレクトされる' do
                stub_response = {
                    ingredients: [
                        { name: "鶏むね肉", amount: 100, unit: "g", protein: 20, fat: 3, carbohydrate: 0 }
                    ],
                    target_pfc: { protein: 30, fat: 10, carbohydrate: 50 },
                    total_pfc: { protein: 25, fat: 8, carbohydrate: 300 }
                }

                allow(Net::HTTP).to receive(:start).and_return(
                    instance_double(Net::HTTPResponse, body: stub_response.to_json)
                )

                allow_any_instance_of(ChatGptService).to receive(:fetch_pfc_prompt).and_return({
                    recipe: {
                        title: "テストレシピ",
                        description: "テスト説明",
                        ingredients: [ { name: "鶏むね肉", amount: "100g" } ],
                        steps: [ "焼く", "食べる" ],
                        nutrition: { calories: "300kcal", protein: "25g", fat: "8g", carbohydrates: "45g" }
                    }
                })

                post searches_optimized_path, params: {
                    target_p: 30,
                    target_f: 10,
                    target_c: 50
                }

                follow_redirect!
                expect(response.body).to include("テストレシピ")
            end
        end
    end

    describe 'DELETE /searches/:id' do
        let!(:search_recipe) { create(:search_recipe, user: user) }
        before { sign_in user }

        context '削除成功' do
            let!(:search_recipe) { create(:search_recipe, user: user) }
            it 'レシピを削除し、レシピ一覧にリダイレクト' do
                expect { delete search_path(search_recipe) }.to change(SearchRecipe, :count).by(-1)
                expect(response).to have_http_status(:found)
                expect(response).to redirect_to(saved_searches_path)
            end
        end

        context '削除失敗(例外)' do
            before do
                allow_any_instance_of(SearchRecipe).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)
            end

            it 'レシピが削除されず、レシピ一覧にリダイレクト' do
                delete search_path(search_recipe)

                expect(response).to have_http_status(:unprocessable_entity)
                expect(response.body).to include("削除に失敗しました")
            end
        end
    end
end
