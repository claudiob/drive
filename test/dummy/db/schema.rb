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

ActiveRecord::Schema[8.1].define(version: 2026_08_04_000008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "phone", null: false
    t.string "surname"
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_contacts_on_phone", unique: true
  end

  create_table "counties", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "fips", limit: 5, null: false
    t.string "name", null: false
    t.bigint "state_id", null: false
    t.datetime "updated_at", null: false
    t.index ["fips"], name: "index_counties_on_fips", unique: true
    t.index ["state_id"], name: "index_counties_on_state_id"
    t.check_constraint "fips::text ~ '^[0-9]{5}$'::text", name: "counties_fips_five_digits"
  end

  create_table "markets", force: :cascade do |t|
    t.datetime "audited_at"
    t.string "color"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name", null: false
    t.time "opens_at"
    t.date "opens_on"
    t.datetime "updated_at", null: false
    t.string "zip", limit: 5
    t.index ["name"], name: "index_markets_on_name", unique: true
  end

  create_table "states", force: :cascade do |t|
    t.string "code", limit: 2, null: false
    t.datetime "created_at", null: false
    t.string "fips", limit: 2, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_states_on_code", unique: true
    t.index ["fips"], name: "index_states_on_fips", unique: true
    t.index ["name"], name: "index_states_on_name", unique: true
    t.check_constraint "code::text ~ '^[A-Z]{2}$'::text", name: "states_code_two_letters"
    t.check_constraint "fips::text ~ '^[0-9]{2}$'::text", name: "states_fips_two_digits"
  end

  add_foreign_key "counties", "states"
end
