require 'rails/generators'
require "rails/generators/active_record"

class EbookGeneratorGenerator < ActiveRecord::Generators::Base
  argument :name, type: :string, default: 'random_name'

  source_root File.expand_path('../../ebook_generator', __FILE__)

  # Copies the migration template to db/migrate.
  def copy_files
    migration_template 'migration.rb', 'db/migrate/create_ebook_generator_tables.rb'
  end

  def create_initializer
    copy_file 'initializer.rb', 'config/initializers/ebook_generator.rb'
  end
end
