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

ActiveRecord::Schema[8.1].define(version: 2025_10_18_065140) do
  create_table "rules", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.string "name"
    t.integer "priority", default: 0
    t.json "properties", default: {}
    t.datetime "starts_at"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["priority"], name: "index_rules_on_priority"
  end
end
