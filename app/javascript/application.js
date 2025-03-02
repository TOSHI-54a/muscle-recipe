// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo"; // Turbo を読み込む
import "./controllers"; // Stimulus コントローラーを読み込む
import "./channels/chat_room_channel";
import "./controllers/menu";
import "./search_loading";

console.log("Rails Application initialized.");
