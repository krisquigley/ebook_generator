class CreateEbooks < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'

    create_table :ebooks, id: :uuid, default: "uuid_generate_v4()" do |t|
      t.string    "title",      null: false
      t.string    "creator"
      t.string    "language",   limit: 2
      t.string    "contributor"
      t.text      "description"
      t.string    "publisher"
      t.text      "rights"
      t.string    "subject"
      t.string    "slug"
      t.datetime  "created_at"
      t.datetime  "updated_at"
    end

    add_index :ebooks, :slug, unique: true
  end
end
