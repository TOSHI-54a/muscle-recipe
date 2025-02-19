import consumer from "./consumer";
console.log("Consumer object:", consumer);

const createChatRoomChannel = (roomId) => {
  return consumer.subscriptions.create({ channel: "ChatRoomChannel", room_id: roomId }, {
    received(data) {
      console.log("📩 New message received:", data);
      const messagesContainer = document.getElementById("messages");
      if (messagesContainer) {
        const currentUserId = document.getElementById("current-user-id")?.value;
        const isCurrentUser = data.user_id == currentUserId;
        const alignmentClass = isCurrentUser ? "justify-end" : "justify-start";
        const bgColorClass = isCurrentUser ? "bg-green-200 text-right" : "bg-gray-100 text-left";

        messagesContainer.insertAdjacentHTML(
          "beforeend",
          `<div class="flex ${alignmentClass}">
            <div class="p-2 w-[70%] ${bgColorClass} rounded-md my-1">
              <strong>${data.user}:</strong> ${data.message}
            </div>
          </div>`
        );
        scrollToBottom();
      }
    },

    sendMessage(message) {
      console.log("Sending message:", message);
      this.perform("receive", { message, room_id: roomId });
    }
  });
};

const initializeChat = () => {
  const chatRoomId = document.getElementById("chat-room-id")?.value;
  const currentUserId = document.getElementById("current-user-id")?.value;

  if (chatRoomId && currentUserId) {
    console.log(`Initializing ChatRoomChannel for room ID: ${chatRoomId}`);
    const chatChannel = createChatRoomChannel(chatRoomId, currentUserId);
    const messageInput = document.getElementById("message-input");
    const sendButton = document.getElementById("send-button");

    if (messageInput && sendButton) {
      sendButton.addEventListener("click", () => {
        const message = messageInput.value.trim();
        if (message !== "") {
          chatChannel.sendMessage(message);
          messageInput.value = "";
        }
      });
    }
  }
};

const scrollToBottom = () => {
  const messagesContainer = document.getElementById("messages");
  if (messagesContainer) {
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
  }
};

document.addEventListener("turbo:load", () => {
  console.log("turbo:load - Initializing Chat");
  initializeChat();
  scrollToBottom();
});


// consumer.subscriptions.create("ChatRoomChannel", {
//   connected() {
//     // Called when the subscription is ready for use on the server
//   },

//   disconnected() {
//     // Called when the subscription has been terminated by the server
//   },

//   received(data) {
//     // Called when there's incoming data on the websocket for this channel
//   }
// });
