# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190413190514) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "general_managers", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "league_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "r1_points"
    t.integer "r2_points"
    t.integer "r3_points"
    t.integer "r4_points"
    t.integer "points"
    t.index ["league_id"], name: "index_general_managers_on_league_id"
    t.index ["user_id"], name: "index_general_managers_on_user_id"
  end

  create_table "goalie_game_statlines", force: :cascade do |t|
    t.integer "skater_id"
    t.string "team"
    t.string "position"
    t.string "opposition"
    t.integer "round"
    t.integer "win"
    t.integer "shutout"
    t.date "game_date"
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "goalies", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "position"
    t.string "team"
    t.integer "number"
    t.integer "wins"
    t.integer "shutouts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "r1_wins"
    t.integer "r1_shutouts"
    t.integer "r2_wins"
    t.integer "r2_shutouts"
    t.integer "r3_wins"
    t.integer "r3_shutouts"
    t.integer "r4_wins"
    t.integer "r4_shutouts"
    t.integer "r1_total"
    t.integer "r2_total"
    t.integer "r3_total"
    t.integer "r4_total"
  end

  create_table "leagues", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "r1_fw_count"
    t.integer "r2_fw_count"
    t.integer "r3_fw_count"
    t.integer "r4_fw_count"
    t.integer "r1_d_count"
    t.integer "r2_d_count"
    t.integer "r3_d_count"
    t.integer "r4_d_count"
    t.integer "r1_g_count"
    t.integer "r2_g_count"
    t.integer "r3_g_count"
    t.integer "r4_g_count"
    t.datetime "scraped_at"
  end

  create_table "players", force: :cascade do |t|
    t.integer "skater_id"
    t.string "position"
    t.string "team"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.integer "number"
    t.integer "rounds"
  end

  create_table "roster_players", force: :cascade do |t|
    t.integer "general_manager_id"
    t.integer "player_id"
    t.integer "league_id"
    t.integer "round"
    t.string "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "round_total", default: 0
    t.index ["general_manager_id"], name: "index_roster_players_on_general_manager_id"
    t.index ["league_id"], name: "index_roster_players_on_league_id"
    t.index ["player_id", "round"], name: "index_roster_players_on_player_id_and_round"
    t.index ["player_id"], name: "index_roster_players_on_player_id"
  end

  create_table "rosters", force: :cascade do |t|
    t.integer "league_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["league_id"], name: "index_rosters_on_league_id"
    t.index ["user_id"], name: "index_rosters_on_user_id"
  end

  create_table "rounds", force: :cascade do |t|
    t.boolean "current_round"
    t.boolean "lineup_changes_allowed"
    t.date "start_date"
    t.date "end_date"
    t.integer "round_number"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "round_finished"
  end

  create_table "scrapers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "skater_game_statlines", force: :cascade do |t|
    t.integer "skater_id"
    t.string "team"
    t.string "position"
    t.string "opposition"
    t.integer "round"
    t.integer "goals"
    t.integer "assists"
    t.integer "points"
    t.integer "game_winning_goals"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "game_date"
    t.integer "game_id"
    t.integer "ot_goals"
    t.index ["skater_id", "round"], name: "index_skater_game_statlines_on_skater_id_and_round"
  end

  create_table "skaters", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "position"
    t.string "team"
    t.integer "goals"
    t.integer "assists"
    t.integer "points"
    t.integer "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "number"
    t.integer "game_winning_goals"
    t.integer "games_played"
    t.integer "r1_goals"
    t.integer "r1_assists"
    t.integer "r1_points"
    t.integer "r1_game_winning_goals"
    t.integer "r2_goals"
    t.integer "r2_assists"
    t.integer "r2_points"
    t.integer "r2_game_winning_goals"
    t.integer "r3_goals"
    t.integer "r3_assists"
    t.integer "r3_points"
    t.integer "r3_game_winning_goals"
    t.integer "r4_goals"
    t.integer "r4_assists"
    t.integer "r4_points"
    t.integer "r4_game_winning_goals"
    t.integer "r1_total"
    t.integer "r2_total"
    t.integer "r3_total"
    t.integer "r4_total"
    t.integer "r1_ot_goals"
    t.integer "r2_ot_goals"
    t.integer "r3_ot_goals"
    t.integer "r4_ot_goals"
    t.integer "ot_goals"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
