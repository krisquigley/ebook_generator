class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections, force: true do |t|
      t.belongs_to  :ebook
      t.string      :title,      null: false
      t.text        :content,    null: false
      t.integer     :position,   null: false
      t.timestamps
    end

    add_index :sections, ["position"], name: "index_sections_on_position", using: :btree
  end
end
