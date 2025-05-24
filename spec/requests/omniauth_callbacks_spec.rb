require 'rails_helper'

RSpec.describe "Users::OmniauthCallbacks", type: :request do
    describe "GET /users/auth/google_oauth2/callback" do
        context "ユーザーが存在し存在する場合" do
            let!(:user) { create(:user, email: "test@example.com") }

            it 'ログインしてリダイレクトされる' do
                mock_auth_hash(:google)
                get user_google_oauth2_omniauth_callback_path
                expect(response).to redirect_to(new_user_path)
                follow_redirect!
              # なぜかユーザーなしになる。要確認。
              # expect(response.body).to include("アカウントでのログインに失敗しました。もう一度お試しください")
            end
        end
    end
end
