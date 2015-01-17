module EbookGenerator
  class Railtie < Rails::Railtie
    rake_tasks do
      spec = Gem::Specification.find_by_name 'ebook_generator'
      load "#{spec.gem_dir}/lib/tasks/ebook_generator_tasks.rake"
    end
  end
end