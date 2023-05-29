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

ActiveRecord::Schema.define(version: 2023_05_28_181747) do

  create_table "competitions", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "status"
    t.integer "stage"
    t.integer "remaining_heats"
    t.string "name"
    t.integer "user_id"
    t.integer "max_stages"
    t.datetime "published_at"
    t.integer "ruleset_id"
    t.datetime "archived_at"
    t.integer "max_vessels_per_player"
    t.string "mode"
    t.integer "max_players_per_heat"
    t.string "secret_key"
    t.index ["name"], name: "index_competitions_on_name", unique: true
  end

  create_table "evolutions", force: :cascade do |t|
    t.string "name"
    t.integer "vessel_id"
    t.integer "user_id"
    t.integer "max_generations"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_evolutions_on_user_id"
    t.index ["vessel_id"], name: "index_evolutions_on_vessel_id"
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
    t.index ["competition_id", "stage", "order"], name: "index_heats_on_competition_id_and_stage_and_order"
  end

  create_table "metrics", force: :cascade do |t|
    t.integer "competition_id"
    t.float "kills"
    t.float "deaths"
    t.float "assists"
    t.float "hits_out"
    t.float "hits_in"
    t.float "dmg_out"
    t.float "dmg_in"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "ram_parts_in"
    t.float "ram_parts_out"
    t.float "mis_parts_in"
    t.float "mis_parts_out"
    t.float "mis_dmg_in"
    t.float "mis_dmg_out"
    t.float "death_order"
    t.float "death_time"
    t.float "wins"
    t.float "roc_parts_in"
    t.float "roc_parts_out"
    t.float "roc_dmg_in"
    t.float "roc_dmg_out"
    t.integer "waypoints"
    t.float "elapsed_time"
    t.float "deviation"
    t.float "ast_parts_in"
    t.index ["competition_id"], name: "index_metrics_on_competition_id"
  end

  create_table "organizers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "competition_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "parts", force: :cascade do |t|
    t.string "name"
    t.float "cost"
    t.float "mass"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "points"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "user_id"
    t.boolean "is_human", default: true
    t.index ["name"], name: "index_players_on_name", unique: true
  end

  create_table "rankings", force: :cascade do |t|
    t.integer "vessel_id"
    t.integer "competition_id"
    t.integer "rank"
    t.float "score"
    t.integer "kills"
    t.integer "deaths"
    t.integer "assists"
    t.integer "hits_out"
    t.integer "hits_in"
    t.float "dmg_out"
    t.float "dmg_in"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "ram_parts_in"
    t.integer "ram_parts_out"
    t.integer "mis_parts_in"
    t.integer "mis_parts_out"
    t.float "mis_dmg_in"
    t.float "mis_dmg_out"
    t.float "death_order"
    t.float "death_time"
    t.integer "wins"
    t.integer "roc_parts_in"
    t.integer "roc_parts_out"
    t.float "roc_dmg_in"
    t.float "roc_dmg_out"
    t.integer "waypoints"
    t.float "elapsed_time"
    t.float "deviation"
    t.integer "ast_parts_in"
    t.index ["competition_id", "vessel_id"], name: "index_rankings_on_competition_id_and_vessel_id"
  end

  create_table "records", force: :cascade do |t|
    t.integer "hits_out"
    t.integer "kills"
    t.integer "deaths"
    t.float "distance"
    t.string "weapon"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "competition_id"
    t.integer "heat_id"
    t.integer "vessel_id"
    t.integer "assists"
    t.integer "hits_in"
    t.integer "wins"
    t.integer "dmg_in"
    t.integer "dmg_out"
    t.integer "ram_parts_in"
    t.integer "ram_parts_out"
    t.integer "mis_parts_in"
    t.integer "mis_parts_out"
    t.float "mis_dmg_in"
    t.float "mis_dmg_out"
    t.float "death_order"
    t.float "death_time"
    t.integer "roc_parts_in"
    t.integer "roc_parts_out"
    t.float "roc_dmg_in"
    t.float "roc_dmg_out"
    t.integer "waypoints"
    t.float "elapsed_time"
    t.float "deviation"
    t.integer "ast_parts_in"
    t.index ["competition_id"], name: "index_records_on_competition_id_and_player_id"
    t.index ["distance"], name: "index_records_on_distance"
  end

  create_table "rules", force: :cascade do |t|
    t.string "strategy"
    t.string "params"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "ruleset_id"
  end

  create_table "rulesets", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "summary"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "provider"
    t.string "uid"
    t.string "remember_token"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "roles_mask"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "variant_assignments", force: :cascade do |t|
    t.integer "variant_id"
    t.integer "vessel_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "variant_group_assignments", force: :cascade do |t|
    t.integer "variant_group_id"
    t.integer "competition_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "variant_groups", force: :cascade do |t|
    t.integer "evolution_id"
    t.integer "generation"
    t.string "keys"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "selection_strategy"
    t.float "spread_factor"
    t.string "baseline_values"
    t.string "generation_strategy"
    t.index ["evolution_id"], name: "index_variant_groups_on_evolution_id"
  end

  create_table "variants", force: :cascade do |t|
    t.integer "variant_group_id"
    t.string "values"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["variant_group_id"], name: "index_variants_on_variant_group_id"
  end

  create_table "vessel_assignments", force: :cascade do |t|
    t.integer "competition_id"
    t.integer "vessel_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "vessels", force: :cascade do |t|
    t.integer "player_id"
    t.string "craft_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_vessels_on_discarded_at"
    t.index ["player_id", "name"], name: "index_vessels_on_player_id_and_name", unique: true
  end

end
