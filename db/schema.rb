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

ActiveRecord::Schema.define(version: 20161211004846) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "affinities", id: false, force: :cascade do |t|
    t.integer "persona_id", null: false
    t.integer "element_id", null: false
    t.string  "effect"
  end

  create_table "arcanas", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "elements", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "persona_skills", id: false, force: :cascade do |t|
    t.integer "persona_id", null: false
    t.integer "skill_id",   null: false
    t.string  "cost"
    t.integer "level"
  end

  create_table "personas", force: :cascade do |t|
    t.string   "name"
    t.integer  "arcana_id"
    t.integer  "level"
    t.string   "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "skills", force: :cascade do |t|
    t.string   "name"
    t.text     "effect"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "personas", "arcanas"
end
