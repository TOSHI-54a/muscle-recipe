class ChatRoomsController < ApplicationController
    before_action :authenticate_user!
    before_action :user_check, only: %i[ show ]

    def new
        @chat_room = ChatRoom.new
    end

    def create
        room_type = create_params[:room_type]
        user_id = create_params[:user_id]
        chat_name = create_params[:chat_name]

        if room_type == "private" && user_id.present?
            other_user = User.find_by(id: user_id)
            if other_user.nil? || other_user == current_user
                flash[:alert] = "無効なユーザーです"
                return redirect_to chat_rooms_path
            end
            # ユーザーのIDをソートして一意の識別キーを作成（3-5 なら "3-5"）
            user_ids = [ current_user.id, other_user.id ].sort.join("-")
            chat_room = ChatRoom.find_or_create_by(room_type: "private", unique_key: user_ids)
            # もし部屋が新規作成された場合、2人のユーザーを登録
            unless chat_room.users.include?(current_user) && chat_room.users.include?(other_user)
                chat_room.users << [ current_user, other_user ]
            end
        elsif room_type == "group"
            chat_room = ChatRoom.create!(room_type: "group", name: chat_name.presence || "Unnamed Group")
            chat_room.users << current_user
        else
            flash[:alert] = "部屋の選択が無効です"
            return redirect_to chat_rooms_path
        end
        redirect_to chat_room_path(chat_room)
    end

    def index
        @chat_rooms = current_user.chat_rooms.where(room_type: "private").includes(:users)
        @open_chat_rooms = ChatRoom.where(room_type: "group")
    end

    def show
        # @chat_room = ChatRoom.find(params[:id])
        @messages = @chat_room.messages.includes(:user)
    end

    def destroy
        delete_chat = ChatRoom.find(params[:id])
        if delete_chat.destroy
            redirect_to chat_rooms_path, notice: "チャットルームを削除しました。"
        end
    end

    # 1on1
    def create_private
        other_user = User.find(params[:user_id])
        chat_room = ChatRoom.find_or_create_by(room_type: "private") do |room|
            room.users << [ current_user, other_user ]
        end
        redirect_to chat_rooms_path(chat_room)
    end

    # グループ
    def create_group
        chat_room = ChatRoom.create!(room_type: "group")
        chat_room.users << current_user
        chat_room.users << User.where(id: params[:user_id])
        redirect_to chat_rooms_path(chat_room)
    end

    def user_check
        @chat_room = ChatRoom.find(params[:id])
        unless @chat_room.users.include?(current_user)
            redirect_to root_path, alert: "アクセス権がありません"
        end
    end

    def create_params
        params.permit(:room_type, :user_id, :chat_name)
    end
end
