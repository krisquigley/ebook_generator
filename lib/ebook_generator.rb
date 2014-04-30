require "ebook_generator/version"
require "ebook_generator/zip_file_processor"
require "builder"

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
    xm = Builder::XmlMarkup.new(:target => file, :indent => 2)
    xm.instruct!
    xm.container("version" => "1.0", "xmlns" => "urn:oasis:names:tc:opendocument:xmlns:container") {
      xm.rootfiles {
        xm.rootfile("full-path" => "OEBPS/content.opf", "media-type" => "application/oebps-package+xml")
      }
    }

    file.close

  end

  def self.generate_mimetype(path)

    File.open(path, "w+") do |f|
      f.write("application/epub+zip")
    end

  end

  def self.copy_style(path)
    FileUtils.cp Rails.root.to_s + "/app/ebook/style.css", path
  end

  def self.generate_sections(path, attrs)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

    attrs.sections.each do |section|
      file = File.new(path + "/Section#{section.position}.html", "wb")

      xm = Builder::XmlMarkup.new(:target => file, :indent => 2)
      xm.instruct!
      xm.declare! :DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.1//EN", "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
      xm.html("xmlns" => "http://www.w3.org/1999/xhtml"){
        xm.head {
          xm.title { attrs.title }
          xm.meta("content" => attrs.title, "name" => "Title")
          xm.meta("content" => attrs.creator, "name" => "Author")
          xm.link("href" => "../Styles/style.css", "rel" => "stylesheet", "type" => "text/css")
        }
        xm.body { |b| b << "<div id=\"#{section.title}\">" + markdown.render(section.content) + "</div>" }
      }

      file.close
    end
  end

  def self.generate_content_opf(path, attrs)
    file = File.new(path + "/content.opf", "wb")

    xm = Builder::XmlMarkup.new(:target => file, :indent => 2)
    xm.instruct!
    xm.package("xmlns" => "http://www.idpf.org/2007/opf", "unique-identifier" => "BookId", "version" => "2.0") {
      xm.metadata("xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:opf" => "http://www.idpf.org/2007/opf") {
        xm.tag!("dc:identifier", attrs.id, "id" => "BookId", "opf:scheme" => "UUID")
        xm.tag!("dc:title", attrs.title)
        xm.tag!("dc:creator", attrs.creator, "opf:role" => "aut")
        xm.tag!("dc:language", attrs.language)
        xm.tag!("dc:date", attrs.updated_at, "opf:event" => "modification")
        xm.tag!("dc:description", attrs.description)
        xm.tag!("dc:publisher", attrs.publisher)
        xm.tag!("dc:rights", attrs.rights)
        xm.tag!("dc:subject", attrs.subject)
        xm.tag!("dc:contributor", attrs.contributor, "opf:role" => "cov")
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

    file.close

  end

  def self.generate_toc_ncx(path, attrs)

    file = File.new(path + "/toc.ncx", "wb")

    xm = Builder::XmlMarkup.new(:target => file, :indent => 2)
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
        xm.text(attrs.title)
      }
      xm.navMap {
        attrs.sections.each do |section|
          xm.navPoint("id" => "navPoint-#{section.position}", "playOrder" => "#{section.position}") {
            xm.navLabel {
              xm.text(section.title)
            }
            xm.content("src" => "Text/Section#{section.position}.html")
          }
        end
      }
    }

    file.close

  end

  def self.change_perms(files)
    files.each do |file|
      FileUtils.chmod 0755, file
    end
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

    # change permissions for files that need to be executable
    files = [path + "/OEBPS/toc.ncx", path + "/OEBPS/content.opf", path + "/mimetype"]
    change_perms(files)

    # zip all files
    zipfile_name = Rails.root.to_s + "/tmp/" + attrs.slug + ".epub"
    zf = ZipFileProcessor.new(path, zipfile_name)
    zf.write

    # Clean up the tmp dir
    remove_tmp_dir(path + "/")

  end

end
