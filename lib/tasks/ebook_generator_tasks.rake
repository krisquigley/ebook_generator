namespace :ebook_generator do
  desc "Generate ebook from html"
  task :to_html => :environment, :file, include do |t, args|
    
    # Can be passed a single file or comma separated list of files
    files = args[:file].split(',')
    files.each do |file|
      book = HtmlToEbook.new(file)
      book.set_title
      book.save
    end
  end
end