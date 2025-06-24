require 'rails_helper'

RSpec.describe "エラーハンドリング", type: :request do
    describe "POST /users" do
        it "内部エラー時、500エラーページが表示" do
            allow_any_instance_of(User).to receive(:save).and_raise(StandardError.new("テスト例外"))

            post users_path, params: { user: { email: "test@example.com", password: "password" } }
            expect(response).to have_http_status(:internal_server_error)
            expect(response.body).to include("サーバーでエラーが発生しました")
        end
    end
end
