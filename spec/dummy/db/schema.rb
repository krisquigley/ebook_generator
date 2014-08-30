# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140416033315) do

  create_table "ebooks", force: true do |t|
    t.string   "title",                 null: false
    t.string   "creator"
    t.string   "language",    limit: 2
    t.string   "contributor"
    t.text     "description"
    t.string   "publisher"
    t.text     "rights"
    t.string   "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "ebooks", ["slug"], name: "index_ebooks_on_slug", unique: true

  create_table "sections", force: true do |t|
    t.string   "title",      null: false
    t.text     "content",    null: false
    t.string   "ebook_id",   null: false
    t.integer  "position",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sections", ["ebook_id"], name: "index_sections_on_ebook_id"
  add_index "sections", ["position"], name: "index_sections_on_position"

end
