class Sections < ActiveRecord::Migration
  def change
    create_table :sections, force: true do |t|
      t.string   :title,      null: false
      t.text     :content,    null: false
      t.string   :ebook_id,   null: false
      t.integer  :position,   null: false
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
