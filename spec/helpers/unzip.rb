require 'rubygems'
require 'zip'

def unzip_file (file, destination)
  Zip::File.open(file) do |zip_file|
    zip_file.each do |f|
      f_path = File.join(destination, f.name)
      FileUtils.mkdir_p(File.dirname(f_path))
      f.extract(f_path)
    end
  end
end
