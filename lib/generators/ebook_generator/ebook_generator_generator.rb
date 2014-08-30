require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

class EbookGeneratorGenerator < ActiveRecord::Generators::Base
  argument :name, type: :string, default: 'random_name'

  source_root File.expand_path('../templates', __FILE__)

  def create_model_files
    template "ebook.rb", "app/models/ebook.rb"
    template "section.rb", "app/models/section.rb"
    migration_template "create_ebooks.rb", "db/migrate/create_ebooks.rb"
    migration_template "create_sections.rb", "db/migrate/create_sections.rb"
  end
end
