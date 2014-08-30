class CreateEbookGeneratorTables < ActiveRecord::Migration
  def change
    create_table "sections", force: true do |t|
      t.string   "title",      null: false
      t.text     "content",    null: false
      t.uuid     "ebook_id",   null: false
      t.integer  "position",   null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "sections", ["ebook_id"], name: "index_sections_on_ebook_id", using: :btree
    add_index "sections", ["position"], name: "index_sections_on_position", using: :btree
  end
end
