
require_relative '../ebook_generator/html_to_ebook'

namespace :ebook_generator do
  desc "Generate ebook from html"
  task :to_html => :environment do 

    # Can be passed a single file or comma separated list of files
    files = ARGV[1].split(',')

    files.each do |file|
      book = HtmlToEbook.new(file)
      book.set_title
      book.set_collection(2)
      book.save
    end
  end
end