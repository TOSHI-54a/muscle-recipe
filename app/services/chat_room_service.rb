class ChatRoomService
    def initialize(current_user, params)
        @current_user = current_user
        @room_type = params[:room_type]
        @user_id = params[:user_id]
        @chat_name = params[:chat_name]
    end

    def call
        if @room_type == "private"
            create_private_room
        elsif @room_type == "group"
            create_group_room
        else
            raise ArgumentError
        end
    end

    def create_private_room
        other_user = User.find(@user_id)
        raise ActiveRecord::RecordNotFound, "無効なユーザーです" if other_user.nil? || other_user == @current_user

        user_ids = [ @current_user.id, other_user.id ].sort.join("-")
        chat_room = ChatRoom.find_or_create_by!(room_type: "private", unique_key: user_ids)

        unless chat_room.users.include?(@current_user) && chat_room.users.include?(other_user)
            chat_room.users << [ @current_user, other_user ]
        end

        chat_room
    end

    def create_group_room
        chat_room = ChatRoom.create!(room_type: "group", name: @chat_name.presence || "名無しのチャットルーム")
        chat_room.users << @current_user
        chat_room
    end
end
