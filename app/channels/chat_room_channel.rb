class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    @chat_room = ChatRoom.find(params[:room_id])
    # チャットルームごとに WebSocket ストリームを作成
    stream_from "chat_room_#{@chat_room.id}"
    Rails.logger.info "✅ Subscribed to chat_room_#{@chat_room.id} as #{connection.current_user.name}" # デバッグ用
  end

  def receive(data)
    Rails.logger.info "📩 Received message: #{data['message']} from #{connection.current_user.name}" # デバッグ用
    message = @chat_room.messages.create!(content: data["message"], user: connection.current_user)
    ActionCable.server.broadcast("chat_room_#{@chat_room.id}", {
      message: message.content,
      user: message.user.name,
      user_id: message.user.id,
      created_at: message.created_at.strftime("%-m/%-d %H:%M")
    })
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
