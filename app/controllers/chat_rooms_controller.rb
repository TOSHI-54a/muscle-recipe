class ChatRoomsController < ApplicationController
    before_action :authenticate_user!
    before_action :user_check, only: %i[ show ]

    def new
        @chat_room = ChatRoom.new
    end

    def create
        begin
            chat_room = ChatRoomService.new(current_user, create_params).call
            redirect_to chat_room_path(chat_room)
        rescue ArgumentError => e
            flash[:alert] = "部屋の選択が無効です"
            redirect_to chat_rooms_path
        rescue ActiveRecord::RecordNotFound => e
            flash[:alert] = "無効なユーザーです"
            redirect_to chat_rooms_path
        end
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
        begin
            delete_chat = ChatRoom.find(params[:id])
            delete_chat.destroy!
            redirect_to chat_rooms_path, notice: "チャットルームを削除しました。"
        rescue ActiveRecord::RecordNotDestroyed => e
            @chat_rooms = current_user.chat_rooms.where(room_type: "private").includes(:users)
            @open_chat_rooms = ChatRoom.where(room_type: "group")
            flash.now[:error] = "削除に失敗しました"
            render :index, status: :unprocessable_entity
        end
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
