namespace :ebook_generator do
  desc "Generate ebook from html"
  task :to_html, :file do |t, args|
    # Can be passed a single file or comma separated list
    files = args[:file].split(',')
    
  end
end