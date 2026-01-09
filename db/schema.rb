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

ActiveRecord::Schema[7.1].define(version: 2026_01_09_134434) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "lines", force: :cascade do |t|
    t.bigint "memo_id", null: false
    t.text "content", null: false
    t.integer "row_order", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["memo_id", "row_order"], name: "index_lines_on_memo_id_and_row_order", unique: true
    t.index ["memo_id"], name: "index_lines_on_memo_id"
  end

  create_table "memo_sets", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "status", default: 0, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "recipient_email"
    t.index ["completed_at"], name: "index_memo_sets_on_completed_at"
    t.index ["user_id", "status"], name: "index_memo_sets_on_user_id_and_status"
    t.index ["user_id"], name: "index_memo_sets_on_user_id"
  end

  create_table "memos", force: :cascade do |t|
    t.bigint "memo_set_id", null: false
    t.string "title", limit: 100, default: "", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["memo_set_id", "position"], name: "index_memos_on_memo_set_id_and_position", unique: true
    t.index ["memo_set_id"], name: "index_memos_on_memo_set_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "lines", "memos"
  add_foreign_key "memo_sets", "users"
  add_foreign_key "memos", "memo_sets"
end
