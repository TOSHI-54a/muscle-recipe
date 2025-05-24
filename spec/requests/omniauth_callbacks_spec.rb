require 'rails_helper'

RSpec.describe "Users::OmniauthCallbacks", type: :request do
    describe "GET /users/auth/google_oauth2/callback" do
        before do
            user = create(:user, :with_google)
            Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
        end

        context "ユーザーが既に存在する場合" do
            it 'ログインしてリダイレクトされる' do
                mock_auth_hash(:google_oauth2)
                get user_google_oauth2_omniauth_callback_path

                expect(response).to redirect_to(root_path)
                follow_redirect!
            end
        end

        context "ユーザーが存在しない場合（バリデーション失敗）" do
            it "登録されず new_user_path にリダイレクトされる" do
                # 無効な email をセット
                OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
                    provider: "google_oauth2",
                    uid: "99999",
                    info: {
                        email: "invalid_email", # ← 不正な形式
                        name: "Bad Email User"
                    },
                    credentials: {
                        token: "bad_token",
                        expires_at: Time.now + 1.week
                    }
                })
                get user_google_oauth2_omniauth_callback_path

                expect(response).to redirect_to(new_user_path)
                follow_redirect!
                expect(response.body).to include("は有効な形式で入力してください")
            end
        end

        context "ユーザーによる認証拒否などで許可コードが返ってこないなど" do
            it "ログインに失敗し、root_pathにリダイレクトされる" do
                OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
                get user_google_oauth2_omniauth_callback_path
                expect(response).to redirect_to(root_path)
                follow_redirect!
                expect(response.body).to include("Authentication failed")
            end
        end
    end
end
