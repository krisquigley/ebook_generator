require "ebook_generator/version"

module EbookGenerator

  # Move writing of files into its own class that accepts an array
  def make_dir(path)
    Dir.mkdir(path, 0777) unless File.exists?(path)
  end

  def initialise_files(path)
    metainf_path = path + "/META-INF"

    Dir.mkdir(metainf_path) unless File.exists?(metainf_path)

    metainf = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
      <container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">
        <rootfiles>
          <rootfile full-path=\"OEBPS/content.opf\" media-type=\"application/oebps-package+xml\"/>
        </rootfiles>
      </container>"

    File.open(metainf_path + "/container.xml", "w+") do |f|
      f.write(metainf)
    end

    mimetype = "application/epub+zip"
    mimetype_path = path + "/mimetype"

    File.open(mimetype_path, "w+") do |f|
      f.write(mimetype)
    end

    FileUtils.chmod 0755, mimetype_path

    content_path = path + "/OEBPS"

    Dir.mkdir(content_path) unless File.exists?(content_path)

    Dir.mkdir(content_path + "/Text") unless File.exists?(content_path + "/Text")

    Dir.mkdir(content_path + "/Styles") unless File.exists?(content_path + "/Styles")

    root = Rails.root.to_s

    FileUtils.cp "#{root}/app/ebook/style.css", content_path+"/Styles"

    return content_path

  end

  def generate_headers(attrs)
    xml = "<title>#{attrs.title}</title>
      <meta content=\"#{attrs.title}\" name=\"Title\" />
      <meta content=\"#{attrs.title}\" name=\"Author\" />
      <link href=\"../Styles/style.css\" rel=\"stylesheet\" type=\"text/css\" />"
    return xml
  end

  def generate_sections(path, attrs)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    headers = generate_headers(attrs)

    attrs.sections.each do |section|
      xml = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>
        <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"
          \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">
        <html xmlns=\"http://www.w3.org/1999/xhtml\">
        <head>
          #{headers}
        </head>
        <body>
          <div id=\"#{section.title}\">
          "
      xml += markdown.render(section.content)
      xml += "
          </div>
        </body>
        </html>"

      File.open(path + "/Section#{section.position}.html", "w+") do |f|
        f.write(xml)
      end
    end
  end

  def generate_content_opf(path, attrs)
    xml = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>
    <package xmlns=\"http://www.idpf.org/2007/opf\" unique-identifier=\"BookId\" version=\"2.0\">
      <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:opf=\"http://www.idpf.org/2007/opf\">
        <dc:identifier id=\"BookId\" opf:scheme=\"UUID\">#{attrs.id}</dc:identifier>
        <dc:title>#{attrs.title}</dc:title>
        <dc:creator opf:role=\"aut\">#{attrs.creator}</dc:creator>
        <dc:language>#{attrs.language}</dc:language>
        <dc:date opf:event=\"modification\">#{attrs.updated_at}</dc:date>
        <dc:description>#{attrs.description}</dc:description>
        <dc:publisher>#{attrs.publisher}</dc:publisher>
        <dc:rights>#{attrs.rights}</dc:rights>
        <dc:subject>#{attrs.subject}</dc:subject>
        <dc:contributor opf:role=\"cov\">#{attrs.contributor}</dc:contributor>
        <meta content=\"0.7.2\" name=\"Sigil version\" />
      </metadata>
      <manifest>
        <item href=\"toc.ncx\" id=\"ncx\" media-type=\"application/x-dtbncx+xml\" />
        <item href=\"Styles/style.css\" id=\"style.css\" media-type=\"text/css\" />"

    attrs.sections.each do |section|
      xml += "<item href=\"Text/Section#{section.position}.html\" id=\"Section#{section.position}.html\" media-type=\"application/xhtml+xml\" />"
    end

    xml += "<item href=\"Fonts/junicode-italic-webfont.ttf\" id=\"junicode-italic-webfont.ttf\" media-type=\"application/x-font-ttf\" />
        <item href=\"Fonts/junicode-webfont.ttf\" id=\"junicode-webfont.ttf\" media-type=\"application/x-font-ttf\" />
        <item href=\"Fonts/junicode-bold-webfont.ttf\" id=\"junicode-bold-webfont.ttf\" media-type=\"application/x-font-ttf\" />
      </manifest>
      <spine toc=\"ncx\">"

    attrs.sections.each do |section|
      xml += "<itemref idref=\"Section#{section.position}.html\" />"

    end
    xml += "</spine>
      <guide />
    </package>"

    content_path = path + "/content.opf"

    File.open(content_path, "w+") do |f|
      f.write(xml)
    end

    FileUtils.chmod 0755, content_path

  end

  def generate_toc_ncx(path, attrs)
    xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>
    <!DOCTYPE ncx PUBLIC \"-//NISO//DTD ncx 2005-1//EN\"
     \"http://www.daisy.org/z3986/2005/ncx-2005-1.dtd\">
    <ncx xmlns=\"http://www.daisy.org/z3986/2005/ncx/\" version=\"2005-1\">
      <head>
        <meta content=\"urn:uuid:${attrs.id}\" name=\"dtb:uid\"/>
        <meta content=\"2\" name=\"dtb:depth\"/>
        <meta content=\"0\" name=\"dtb:totalPageCount\"/>
        <meta content=\"0\" name=\"dtb:maxPageNumber\"/>
      </head>
      <docTitle>
        <text>#{attrs.title}</text>
      </docTitle>
      <navMap>"


    attrs.sections.each do |section|
      xml += "<navPoint id=\"navPoint-#{section.position}\" playOrder=\"#{section.position}\">
        <navLabel>
          <text>#{section.title}</text>
        </navLabel>
        <content src=\"Text/Section#{section.position}.html\"/>
      </navPoint>"
    end

    xml += "</navMap>
    </ncx>"

    toc_path = path + "/toc.ncx"

    File.open(toc_path, "w+") do |f|
      f.write(xml)
    end

    FileUtils.chmod 0755, toc_path
  end

  def remove_tmp_dir(directory)
    FileUtils.remove_dir(directory, true)
  end

  def generate_ebook(ebook_id)

    # create tmp directory based on UUID
    path = Rails.root.join "tmp/#{ebook_id}"
    make_dir(path.to_s)

    # set up required files and dirs
    content_path = initialise_files(path.to_s)

    # loop through each section loading the reference header and saving as it's own section
    attrs = Ebook.find(ebook_id)
    generate_sections(content_path + "/Text", attrs)

    # generate toc based on the number of sections generated
    generate_content_opf(content_path, attrs)
    generate_toc_ncx(content_path, attrs)

    # zip all files
    zipfile_name = Rails.root.to_s + "/tmp/" + attrs.slug + ".epub"

    zf = ZipFileProcessor.new(path.to_s, zipfile_name)
    zf.write

    # Clean up the tmp dir
    remove_tmp_dir(path.to_s + "/")

  end

end
