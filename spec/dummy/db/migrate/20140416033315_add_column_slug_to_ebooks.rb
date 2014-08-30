class AddColumnSlugToEbooks < ActiveRecord::Migration
  def change
    add_column :ebooks, :slug, :string
    add_index :ebooks, :slug, unique: true
  end
end
