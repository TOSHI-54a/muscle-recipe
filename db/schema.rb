# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_04_10_062134) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chat_room_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "chat_room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_room_id"], name: "index_chat_room_users_on_chat_room_id"
    t.index ["user_id"], name: "index_chat_room_users_on_user_id"
  end

  create_table "chat_rooms", force: :cascade do |t|
    t.string "room_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "unique_key"
    t.index ["unique_key"], name: "index_chat_rooms_on_unique_key", unique: true
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "search_recipe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["search_recipe_id"], name: "index_likes_on_search_recipe_id"
    t.index ["user_id", "search_recipe_id"], name: "index_likes_on_user_id_and_search_recipe_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.bigint "user_id", null: false
    t.bigint "chat_room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_room_id"], name: "index_messages_on_chat_room_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "search_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "session_id"
    t.string "ip_address"
    t.datetime "search_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_search_logs_on_user_id"
  end

  create_table "search_recipes", force: :cascade do |t|
    t.bigint "user_id"
    t.string "query", null: false
    t.datetime "search_time", null: false
    t.jsonb "response_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_search_recipes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "age"
    t.integer "height"
    t.integer "weight"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "gender"
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chat_room_users", "chat_rooms"
  add_foreign_key "chat_room_users", "users"
  add_foreign_key "likes", "search_recipes"
  add_foreign_key "likes", "users"
  add_foreign_key "messages", "chat_rooms"
  add_foreign_key "messages", "users"
  add_foreign_key "search_logs", "users"
  add_foreign_key "search_recipes", "users"
end
