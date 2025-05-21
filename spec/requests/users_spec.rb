require 'rails_helper'

RSpec.describe "Users", type: :request do
    let(:user) { create(:user) } # FactoryBot
    let(:other_user) { create(:user) } # 他のユーザー

    before do
        I18n.locale = :ja
    end

    describe "GET /users/new" do
        it 'userの新規登録画面' do
            get new_user_path
            expect(response).to have_http_status(200)
        end
    end
    describe "GET /users/:id" do
        context '未ログインの場合' do
            it '302リダイレクト（ログインページへ）' do
                get user_path(user.id)
                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_user_session_path)
            end
        end

        context 'ログイン済みの場合' do
            it '200 ok を返す' do
                sign_in user
                get user_path(user.id)
                expect(response).to have_http_status(200)
            end
        end
    end
    describe 'POST /users' do
        let(:valid_params) { { user: attributes_for(:user) } }
        it 'ユーザーを作成し、リダイレクト' do
            expect {
                post users_path, params: valid_params
            }.to change(User, :count).by(1)
            expect(response).to have_http_status(302)
        end
    end

    describe 'GET /users/:id/edit' do
        context '未ログインの場合' do
            it '302リダイレクト（ログインページへ)' do
                get edit_user_path(user)
                expect(response).to have_http_status(302)
                expect(response).to redirect_to(new_user_session_path)
            end
        end
        context 'ログイン済みかつ本人の場合' do
            it '200ok' do
                sign_in user
                get edit_user_path(user)
                expect(response).to have_http_status(200)
            end
        end
        context '別のユーザーの場合' do
            it '302リダイレクト' do
                sign_in other_user
                get edit_user_path(user)
                expect(response).to have_http_status(302)
                expect(response).to redirect_to(user_path(other_user))
            end
        end
    end

    describe 'PATCH /users/:id' do
        context 'パスワードなしで有効な情報を送信した場合' do
            it '更新に成功し、リダイレクト' do
                sign_in user
                patch user_path(user), params: {
                    user: {
                        name: "新しい名前",
                        password: "",
                        password_confirmation: ""
                    }
                }
                expect(response).to redirect_to(user_path(user))
                follow_redirect!
                expect(response.body).to include(I18n.t("users.update.success"))
                expect(user.reload.name).to eq("新しい名前")
            end
        end

        context 'パスワードありで有効な情報を送信した場合' do
            it '更新に成功し、リダイレクト' do
                sign_in user
                patch user_path(user), params: {
                    user: {
                        name: "パス付き更新",
                        current_password: "password",
                        password: "newpassword",
                        password_confirmation: "newpassword"
                    }
                }
                expect(response).to redirect_to(user_path(user))
                follow_redirect!
                expect(response.body).to include(I18n.t("users.update.success"))
                expect(user.reload.name).to eq("パス付き更新")
                expect(user.valid_password?("newpassword")).to be true
            end
        end

        context '無効なパラメータを送信した場合' do
            it '更新されず edit 再表示' do
                sign_in user
                patch user_path(user), params: {
                    user: {
                        name: "",
                        password: "",
                        password_confirmation: ""
                    }
                }
                expect(response).to have_http_status(:unprocessable_entity)
                expect(response.body).to include(I18n.t("errors.messages.blank"))
            end
        end
    end

    describe 'DELETE /users/:id' do
        context 'ログイン済みかつ本人の場合' do
            it 'アカウントを削除し、ログインページへリダイレクト' do
                sign_in user
                expect { delete user_path(user) }.to change(User, :count).by(-1)
                expect(response).to have_http_status(303)
                expect(response).to redirect_to(user_session_path)
            end
        end
        context '別のユーザーの場合' do
            it '302リダイレクト(other_userのプロフィールへ)' do
                sign_in other_user
                delete user_path(user)
                expect(response).to have_http_status(302)
                expect(response).to redirect_to(user_path(other_user))
            end
        end
    end
end
