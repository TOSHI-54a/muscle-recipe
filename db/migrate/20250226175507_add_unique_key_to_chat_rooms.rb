class AddUniqueKeyToChatRooms < ActiveRecord::Migration[7.2]
  def change
    add_column :chat_rooms, :unique_key, :string
    add_index :chat_rooms, :unique_key, unique: true
  end
end
