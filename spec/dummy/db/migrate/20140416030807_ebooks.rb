class Ebooks < ActiveRecord::Migration
  def change
    create_table :ebooks, force: true do |t|
      t.string    :title,      null: false
      t.string    :creator
      t.string    :language,   limit: 2
      t.string    :contributor
      t.text      :description
      t.string    :publisher
      t.text      :rights
      t.string    :subject

      t.datetime  :created_at
      t.datetime  :updated_at
    end
  end
end
