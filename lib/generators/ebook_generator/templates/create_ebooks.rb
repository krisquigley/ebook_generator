class CreateEbooks < ActiveRecord::Migration
  def change
    create_table :ebooks, force: true  do |t|
      t.string    :title,      null: false
      t.string    :creator
      t.string    :language,   limit: 2, null: false
      t.string    :contributor
      t.text      :description
      t.string    :publisher
      t.text      :rights
      t.string    :subject
      t.string    :slug,       null: false
      t.timestamps
    end

    add_index :ebooks, :slug, unique: true
  end
end
