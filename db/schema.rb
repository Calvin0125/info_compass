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

ActiveRecord::Schema.define(version: 2021_06_03_174856) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "research_articles", force: :cascade do |t|
    t.string "title"
    t.string "author_csv"
    t.string "summary"
    t.string "api"
    t.string "api_id"
    t.string "research_topic_id"
    t.date "article_published"
    t.date "article_updated"
    t.boolean "new"
    t.boolean "saved"
    t.boolean "read"
    t.boolean "not_interested"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "research_topics", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "search_terms", force: :cascade do |t|
    t.string "term"
    t.integer "research_topic_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
