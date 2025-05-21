require 'rails_helper'

RSpec.describe 'Homes', type: :request do
    describe 'GET /' do
        it 'ホーム画面にアクセスできる' do
            get root_path
            expect(response).to have_http_status(:ok)
        end
    end
end
