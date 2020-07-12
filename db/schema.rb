# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_12_152348) do

  create_table "competitions", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status"
    t.integer "stage"
    t.integer "remaining_heats"
    t.string "name"
    t.index ["name"], name: "index_competitions_on_name", unique: true
  end

  create_table "heat_assignments", force: :cascade do |t|
    t.integer "heat_id"
    t.integer "vessel_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "heats", force: :cascade do |t|
    t.integer "competition_id"
    t.integer "stage"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "order"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.index ["competition_id", "order"], name: "index_heats_on_competition_id_and_order", unique: true
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_players_on_name", unique: true
  end

  create_table "records", force: :cascade do |t|
    t.integer "hits"
    t.integer "kills"
    t.integer "deaths"
    t.float "distance"
    t.string "weapon"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "competition_id"
    t.integer "heat_id"
    t.integer "vessel_id"
    t.index ["competition_id", "heat_id", "vessel_id"], name: "index_records_on_competition_id_and_heat_id_and_vessel_id", unique: true
    t.index ["distance"], name: "index_records_on_distance"
  end

  create_table "vessels", force: :cascade do |t|
    t.integer "player_id"
    t.string "craft_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "competition_id"
    t.index ["competition_id"], name: "index_vessels_on_competition_id"
  end

end
