class AddIndexToSectionsEbookIdPosition < ActiveRecord::Migration
  def change
    add_index :sections, ["ebook_id"], name: "index_sections_on_ebook_id", using: :btree
    add_index :sections, ["position"], name: "index_sections_on_position", using: :btree
  end
end
