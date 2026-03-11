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

ActiveRecord::Schema[8.1].define(version: 2026_03_09_000001) do
  create_table "config", force: :cascade do |t|
    t.string "key", limit: 40, default: "", null: false
    t.string "value", default: ""
    t.index ["key"], name: "key", unique: true
  end

  create_table "extension_meta", force: :cascade do |t|
    t.boolean "enabled", default: true
    t.string "name"
    t.integer "schema_version", default: 0
  end

  create_table "layouts", force: :cascade do |t|
    t.text "content"
    t.string "content_type", limit: 40
    t.datetime "created_at"
    t.integer "created_by_id"
    t.integer "lock_version", default: 0
    t.string "name", limit: 100
    t.datetime "updated_at"
    t.integer "updated_by_id"
  end

  create_table "page_fields", force: :cascade do |t|
    t.string "content"
    t.string "name"
    t.integer "page_id"
    t.index ["page_id", "name", "content"], name: "index_page_fields_on_page_id_and_name_and_content"
  end

  create_table "page_parts", force: :cascade do |t|
    t.text "content"
    t.string "filter_id", limit: 25
    t.string "name", limit: 100
    t.integer "page_id"
    t.index ["page_id", "name"], name: "parts_by_page"
  end

  create_table "pages", force: :cascade do |t|
    t.text "allowed_children_cache"
    t.string "breadcrumb", limit: 160
    t.string "class_name", limit: 25
    t.datetime "created_at"
    t.integer "created_by_id"
    t.integer "layout_id"
    t.integer "lock_version", default: 0
    t.integer "parent_id"
    t.datetime "published_at"
    t.string "slug", limit: 100
    t.integer "status_id", default: 1, null: false
    t.string "title"
    t.datetime "updated_at"
    t.integer "updated_by_id"
    t.boolean "virtual", default: false, null: false
    t.index ["class_name"], name: "altered_pages_class_name"
    t.index ["parent_id"], name: "altered_pages_parent_id"
    t.index ["slug", "parent_id"], name: "altered_pages_child_slug"
    t.index ["virtual", "status_id"], name: "altered_pages_published"
  end

  create_table "sessions", force: :cascade do |t|
    t.text "data"
    t.string "session_id"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "snippets", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at"
    t.integer "created_by_id"
    t.string "filter_id", limit: 25
    t.integer "lock_version", default: 0
    t.string "name", limit: 100, default: "", null: false
    t.datetime "updated_at"
    t.integer "updated_by_id"
    t.index ["name"], name: "name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at"
    t.integer "created_by_id"
    t.boolean "designer", default: false, null: false
    t.string "email"
    t.string "locale"
    t.integer "lock_version", default: 0
    t.string "login", limit: 40, default: "", null: false
    t.string "name", limit: 100
    t.text "notes"
    t.string "password_digest"
    t.datetime "updated_at"
    t.integer "updated_by_id"
    t.index ["login"], name: "login", unique: true
  end
end
