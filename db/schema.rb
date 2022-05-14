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

ActiveRecord::Schema.define(version: 2022_04_28_104649) do

  create_table "hops", charset: "latin1", force: :cascade do |t|
    t.bigint "session_id"
    t.string "input"
    t.string "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_hops_on_session_id"
  end

  create_table "sessions", charset: "latin1", force: :cascade do |t|
    t.string "provider_session_id"
    t.string "page_ref"
    t.string "msisdn"
    t.json "data"
    t.string "provider_key"
    t.string "instance_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_code"
    t.integer "network_code"
    t.index ["created_at"], name: "index_sessions_on_created_at"
    t.index ["msisdn"], name: "index_sessions_on_msisdn"
    t.index ["provider_session_id", "provider_key"], name: "index_sessions_on_provider_session_id_and_provider_key", unique: true
  end

  add_foreign_key "hops", "sessions"
end
