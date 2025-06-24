// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import * as Turbo from "@hotwired/turbo";
Turbo.session.drive = true;
// import Stimulus from "@hotwired/stimulus";
import "./controllers"; // Stimulus コントローラーを読み込む
import "./channels/chat_room_channel";
// import "./controllers/menu";
import "./search_loading";

// Turboを明示的に有効化
Turbo.session.drive = true;
console.log("🚀 Turbo is enabled!");

window.addEventListener("turbo:click", (event) => {
    console.log("🖱️ Turbo Click detected:", event.target);
  });

// Turboのロードを監視
document.addEventListener("turbo:load", () => {
  console.log("🚀 Turbo loaded successfully!");
});
