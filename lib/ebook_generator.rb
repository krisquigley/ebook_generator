require "ebook_generator/version"
require "ebook_generator/zip_file_processor"

module EbookGenerator

  def self.included(model_class)
    model_class.extend self
  end

  # Move writing of files into its own class that accepts an array
  def self.make_dirs(paths)
    paths.each do |path|
      Dir.mkdir(path, 0777) unless File.exists?(path)
    end
  end

  def self.generate_container(path)

    file = File.new(path + "/container.xml", "wb")
    xm = Builder::XmlMarkup.new :target => file
    xm.instruct!
    xm.container("version" => "1.0", "xmlns" => "urn:oasis:names:tc:opendocument:xmlns:container") {
      xm.rootfiles {
        xm.rootfile("full-path" => "OEBPS/content.opf", "media-type" => "application/oebps-package+xml")
      }
    }

    file.close

  end

  def generate_mimetype(path)

    File.open(path, "w+") do |f|
      f.write("application/epub+zip")
    end

    FileUtils.chmod 0755, path

  end

  def copy_style(path)
    FileUtils.cp "#{root}/app/ebook/style.css", path
  end

  def self.generate_headers(attrs)
    xm = Builder::XmlMarkup.new
    xm.title { attrs.title }
    xm.meta("content" => attrs.title, "name" => "Title")
    xm.meta("content" => attrs.author, "name" => "Author")
    xm.link("href" => "../Styles/style.css", "rel" => "stylesheet", "type" => "text/css")
    # xml = "<title>#{attrs.title}</title>
    #   <meta content=\"#{attrs.title}\" name=\"Title\" />
    #   <meta content=\"#{attrs.title}\" name=\"Author\" />
    #   <link href=\"../Styles/style.css\" rel=\"stylesheet\" type=\"text/css\" />"
    return xm
  end

  def self.generate_sections(path, attrs)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

    attrs.sections.each do |section|
      file = File.new(path + "/Section#{section.position}.html", "wb")

      xm = Builder::XmlMarkup.new :target => file
      xm.instruct!
      xm.declare! :DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.1//EN", "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
      xm.html("xmlns" => "http://www.w3.org/1999/xhtml"){
        xm.head {
          xm.title { attrs.title }
          xm.meta("content" => attrs.title, "name" => "Title")
          xm.meta("content" => attrs.author, "name" => "Author")
          xm.link("href" => "../Styles/style.css", "rel" => "stylesheet", "type" => "text/css")
        }
        xm.body{
          xm.div("id" => section.title){
            markdown.render(section.content)
          }
        }
      }
      # xml = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"no\"?>
      #   <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"
      #     \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">
      #   <html xmlns=\"http://www.w3.org/1999/xhtml\">
      #   <head>
      #     #{headers}
      #   </head>
      #   <body>
      #     <div id=\"#{section.title}\">
      #     "
      # xml += markdown.render(section.content)
      # xml += "
      #     </div>
      #   </body>
      #   </html>"

      file.close
    end
  end

  def self.generate_content_opf(path, attrs)
    file = File.new(path + "/content.opf", "wb")

    xm = Builder::XmlMarkup.new :target => file
    xm.instruct!
    xm.package("xmlns" => "http://www.idpf.org/2007/opf", "unique-identifier" => "BookId", "version" => "2.0") {
      xm.metadata("xmlsns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:opf" => "http://www.idpf.org/2007/opf") {
        xm.tag!("dc:identifier", "id" => "BookId", "opf:scheme" => "UUID") {
          attrs.id
        }
        xm.tag!("dc:title") {
          attrs.title
        }
        xm.tag!("dc:creator", "opf:role" => "aut") {
          attrs.creator
        }
        xm.tag!("dc:language") {
          attrs.language
        }
        xm.tag!("dc:date", "opf:event" => "modification") {
          attrs.updated_at
        }
        xm.tag!("dc:description") {
          attrs.description
        }
        xm.tag!("dc:publisher") {
          attrs.publisher
        }
        xm.tag!("dc:rights") {
          attrs.rights
        }
        xm.tag!("dc:subject") {
          attrs.subject
        }
        xm.tag!("dc:contributor", "ofp:role" => "cov") {
          attrs.contributor
        }
      }
      xm.manifest {
        xm.item("href" => "toc.ncx", "id" => "ncx", "media-type" => "application/x-dtbncx+xml")
        xm.item("href" => "Styles/style.css", "media-type" => "text/css")
        attrs.sections.each do |section|
          xm.item("href" => "Text/Section#{section.position}.html", "id" => "Section#{section.position}.html", "media-type" => "application/xhtml+xml")
        end
      }
      xm.spine("toc" => "ncx") {
        attrs.sections.each do |section|
          xm.itemref("idref" => "Section#{section.position}.html")
        end
      }
      xm.guide()
    }

    # xml = "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?>
    # <package xmlns=\"http://www.idpf.org/2007/opf\" unique-identifier=\"BookId\" version=\"2.0\">
    #   <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:opf=\"http://www.idpf.org/2007/opf\">
    #     <dc:identifier id=\"BookId\" opf:scheme=\"UUID\">#{attrs.id}</dc:identifier>
    #     <dc:title>#{attrs.title}</dc:title>
    #     <dc:creator opf:role=\"aut\">#{attrs.creator}</dc:creator>
    #     <dc:language>#{attrs.language}</dc:language>
    #     <dc:date opf:event=\"modification\">#{attrs.updated_at}</dc:date>
    #     <dc:description>#{attrs.description}</dc:description>
    #     <dc:publisher>#{attrs.publisher}</dc:publisher>
    #     <dc:rights>#{attrs.rights}</dc:rights>
    #     <dc:subject>#{attrs.subject}</dc:subject>
    #     <dc:contributor opf:role=\"cov\">#{attrs.contributor}</dc:contributor>
    #     <meta content=\"0.7.2\" name=\"Sigil version\" />
    #   </metadata>
    #   <manifest>
    #     <item href=\"toc.ncx\" id=\"ncx\" media-type=\"application/x-dtbncx+xml\" />
    #     <item href=\"Styles/style.css\" id=\"style.css\" media-type=\"text/css\" />"

    # attrs.sections.each do |section|
    #   xml += "<item href=\"Text/Section#{section.position}.html\" id=\"Section#{section.position}.html\" media-type=\"application/xhtml+xml\" />"
    # end
    #
    # xml += "<item href=\"Fonts/junicode-italic-webfont.ttf\" id=\"junicode-italic-webfont.ttf\" media-type=\"application/x-font-ttf\" />
    #     <item href=\"Fonts/junicode-webfont.ttf\" id=\"junicode-webfont.ttf\" media-type=\"application/x-font-ttf\" />
    #     <item href=\"Fonts/junicode-bold-webfont.ttf\" id=\"junicode-bold-webfont.ttf\" media-type=\"application/x-font-ttf\" />
    #   </manifest>
    #   <spine toc=\"ncx\">"
    #
    # attrs.sections.each do |section|
    #   xml += "<itemref idref=\"Section#{section.position}.html\" />"
    #
    # end
    # xml += "</spine>
    #   <guide />
    # </package>"

    file.close

    FileUtils.chmod 0755, path + "/content.opf"

  end

  def self.generate_toc_ncx(path, attrs)

    file = File.new(path + "/toc.ncx", "wb")

    xm = Builder::XmlMarkup.new :target => file
    xm.instruct!
    xm.declare! :DOCTYPE, :ncx, :PUBLIC, "-//NISO//DTD ncx 2005-1//EN", "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd"
    xm.ncx("xmlns" => "http://www.daisy.org/z3986/2005/ncx/", "version" => "2005-1") {
      xm.head {
        xm.meta("content" => "urn:uuid:${attrs.id}", "name" => "dtb:uid")
        xm.meta("content" => "2", "name" => "dtb:depth")
        xm.meta("content" => "0", "name" => "dtb:totalPageCount")
        xm.meta("content" => "0", "name" => "dtb:maxPageNumber")
      }
      xm.docTitle {
        xm.text {
          attrs.totle
        }
      }
      xm.navMap {
        attrs.sections.each do |section|
          xm.navPoint("id" => "navPoint-#{section.position}", "playOrder" => "#{section.position}") {
            xm.navLabel {
              xm.text {
                section.title
              }
            }
            xm.content("src" => "Text/Section#{section.position}.html")
          }
        end
      }
    }

    # xml = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>
    # <!DOCTYPE ncx PUBLIC \"-//NISO//DTD ncx 2005-1//EN\"
    #  \"http://www.daisy.org/z3986/2005/ncx-2005-1.dtd\">
    # <ncx xmlns=\"http://www.daisy.org/z3986/2005/ncx/\" version=\"2005-1\">
    #   <head>
    #     <meta content=\"urn:uuid:${attrs.id}\" name=\"dtb:uid\"/>
    #     <meta content=\"2\" name=\"dtb:depth\"/>
    #     <meta content=\"0\" name=\"dtb:totalPageCount\"/>
    #     <meta content=\"0\" name=\"dtb:maxPageNumber\"/>
    #   </head>
    #   <docTitle>
    #     <text>#{attrs.title}</text>
    #   </docTitle>
    #   <navMap>"
    #
    #
    # attrs.sections.each do |section|
    #   xml += "<navPoint id=\"navPoint-#{section.position}\" playOrder=\"#{section.position}\">
    #     <navLabel>
    #       <text>#{section.title}</text>
    #     </navLabel>
    #     <content src=\"Text/Section#{section.position}.html\"/>
    #   </navPoint>"
    # end
    #
    # xml += "</navMap>
    # </ncx>"

    file.close

    FileUtils.chmod 0755, path + "/toc.ncx"
  end

  def self.remove_tmp_dir(directory)
    FileUtils.remove_dir(directory, true)
  end

  def self.generate_ebook(ebook_id)

    # Set the root path of the ebook
    path = Rails.root.to_s + "/tmp/#{ebook_id}"

    # Make all required dirs
    dirs = [path, path + "/META-INF", path + "/OEBPS", path + "/OEBPS/Text", path + "/OEBPS/Styles"]
    make_dirs(dirs)

    # Create container.xml
    generate_container(path + "/META-INF")

    # Create mimetype
    generate_mimetype(path + "/mimetype")

    # Move default stylesheet into styles folder
    copy_style(path + "/OEBPS/Styles")

    # loop through each section loading the reference header and saving as it's own section
    attrs = Ebook.find(ebook_id)
    generate_sections(path + "/OEBPS/Text", attrs)

    # generate toc based on the number of sections generated
    generate_content_opf(path + "/OEBPS", attrs)
    generate_toc_ncx(path + "/OEBPS", attrs)

    # zip all files
    zipfile_name = Rails.root.to_s + "/tmp/" + attrs.slug + ".epub"
    zf = ZipFileProcessor.new(path, zipfile_name)
    zf.write

    # Clean up the tmp dir
    remove_tmp_dir(path + "/")

  end

end
