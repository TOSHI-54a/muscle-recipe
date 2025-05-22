require 'rails_helper'

RSpec.describe "ChatRooms", type: :request do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    describe 'GET /new' do
        context 'ログイン済み' do
            it '表示される' do
            end
        end
    end

    describe 'POST /chat_rooms' do
        context 'privateチャット作成' do
            it '新しいチャットを作成' do
                sign_in user
                expect {
                    post chat_rooms_path, params: { room_type: 'private', user_id: other_user.id }
                }.to change(ChatRoom, :count).by(1)
                expect(response).to redirect_to(chat_room_path(ChatRoom.last))
            end
        end

        context 'groupチャット作成' do
            it '名前ありで作成' do
                sign_in user
                expect {
                    post chat_rooms_path, params: { room_type: 'group', chat_name: 'テストグループ' }
                }.to change(ChatRoom, :count).by(1)
                expect(ChatRoom.last.name).to eq('テストグループ')
            end
        end

        context '不正なroom_type' do
            it 'リダイレクト' do
                sign_in user
                post chat_rooms_path, params: { room_type: 'invalid', user_id: other_user.id }
                expect(response).to redirect_to(chat_rooms_path)
                follow_redirect!
                expect(response.body).to include("部屋の選択が無効です")
            end

            it '自分自身を選択した場合、エラーとなりリダイレクト' do
                sign_in user
                post chat_rooms_path, params: { room_type: 'private', user_id: user.id }
                expect(response).to redirect_to chat_rooms_path
                follow_redirect!
                expect(response.body).to include("無効なユーザーです")
            end
        end
    end

    describe 'GET /chat_rooms/:id' do
        context 'ユーザーチェック' do
            let!(:chat_room) { create(:chat_room, :private_with_users, user_a: user, user_b: other_user) }
            let!(:different_user) { create(:user) }
            before { sign_in different_user }

            it 'privateチャットに別のユーザーがアクセスするとエラーとなり、ルートへリダイレクト' do
                get chat_room_path(chat_room)
                expect(response).to redirect_to(root_path)
                follow_redirect!
                expect(response.body).to include("アクセス権がありません")
            end
        end
    end

    describe 'DELETE /chat_rooms/:id' do
        context '正常な削除' do
            let!(:chat_room) { create(:chat_room, :private_with_users, user_a: user, user_b: other_user) }
            before { sign_in user }

            it 'privateチャットルームを削除して、リダイレクト' do
                expect {
                    delete chat_room_path(chat_room)
                }.to change(ChatRoom, :count).by(-1)
                expect(response).to redirect_to(chat_rooms_path)
                follow_redirect!
                expect(response.body).to include("チャットルームを削除しました")
            end
        end

        context '削除失敗(例外)' do
            let!(:chat_room) { create(:chat_room, :private_with_users, user_a: user, user_b: other_user) }
            before do
                sign_in user
                allow_any_instance_of(ChatRoom).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)
            end

            it 'チャットルームが削除されず、チャット一覧にリダイレクト' do
                delete chat_room_path(chat_room)
                expect(response).to have_http_status(:unprocessable_entity)
                expect(response.body).to include("削除に失敗しました")
            end
        end
    end
end
