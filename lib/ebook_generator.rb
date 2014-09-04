require "ebook_generator/version"
require "ebook_generator/zip_file_processor"
require "builder"
require "redcarpet"

module EbookGenerator

  # def self.included(model_class)
  #   model_class.extend self
  # end

  def self.generate_ebook(ebook_object, file_type = 'ibook')
    # Set the root path of the ebook
    path = Rails.root.to_s + "/tmp/#{ebook_object.id}"

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
    generate_sections(path + "/OEBPS/Text", ebook_object)

    # generate toc based on the number of sections generated
    generate_content_opf(path + "/OEBPS", ebook_object)
    generate_toc_ncx(path + "/OEBPS", ebook_object)

    # change permissions for files that need to be executable
    files = [path + "/OEBPS/toc.ncx", path + "/OEBPS/content.opf", path + "/mimetype"]
    change_perms(files)

    # zip all files
    zipfile_name = Rails.root.to_s + "/tmp/" + ebook_object.slug + ".epub"
    zf = ZipFileProcessor.new(path, zipfile_name)
    zf.write

    # Clean up the tmp dir
    remove_tmp_dir(path + "/")

    # return the file path
    if file_type == 'ibook'
      zipfile_name
    elsif file_type == 'kindle'
      zipfile_name = generate_mobi(zipfile_name, ebook_object.slug)
    end
  end

  private

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
    # Removed until functionality to dynamically create the stylesheet is in place
    #FileUtils.cp Rails.root.to_s + "/app/ebook/style.css", path
  end

  def self.convert_to_html(content)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    markdown.render(content)
  end

  def self.generate_sections(path, ebook_object)
    ebook_object.sections.each do |section|
      file = File.new(path + "/Section#{section.position}.html", "wb")

      xm = Builder::XmlMarkup.new(:target => file, :indent => 2)
      xm.instruct!
      xm.declare! :DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.1//EN", "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
      xm.html("xmlns" => "http://www.w3.org/1999/xhtml"){
        xm.head {
          xm.title { ebook_object.title }
          xm.meta("content" => ebook_object.title, "name" => "Title")
          xm.meta("content" => ebook_object.creator, "name" => "Author")
          xm.link("href" => "../Styles/style.css", "rel" => "stylesheet", "type" => "text/css")
        }
        xm.body { |b| b << "<div id=\"#{section.title}\">" + convert_to_html(section.content) + "</div>" }
      }

      file.close
    end
  end

  def self.generate_content_opf(path, ebook_object)
    file = File.new(path + "/content.opf", "wb")

    xm = Builder::XmlMarkup.new(:target => file, :indent => 2)
    xm.instruct!
    xm.package("xmlns" => "http://www.idpf.org/2007/opf", "unique-identifier" => "BookId", "version" => "2.0") {
      xm.metadata("xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:opf" => "http://www.idpf.org/2007/opf") {
        xm.tag!("dc:identifier", ebook_object.id, "id" => "BookId", "opf:scheme" => "UUID")
        xm.tag!("dc:title", ebook_object.title)
        xm.tag!("dc:creator", ebook_object.creator, "opf:role" => "aut")
        xm.tag!("dc:language", ebook_object.language)
        xm.tag!("dc:date", ebook_object.updated_at, "opf:event" => "modification")
        xm.tag!("dc:description", ebook_object.description)
        xm.tag!("dc:publisher", ebook_object.publisher)
        xm.tag!("dc:rights", ebook_object.rights)
        xm.tag!("dc:subject", ebook_object.subject)
        xm.tag!("dc:contributor", ebook_object.contributor, "opf:role" => "cov")
      }
      xm.manifest {
        xm.item("href" => "toc.ncx", "id" => "ncx", "media-type" => "application/x-dtbncx+xml")
        xm.item("href" => "Styles/style.css", "media-type" => "text/css")
        ebook_object.sections.each do |section|
          xm.item("href" => "Text/Section#{section.position}.html", "id" => "Section#{section.position}.html", "media-type" => "application/xhtml+xml")
        end
      }
      xm.spine("toc" => "ncx") {
        ebook_object.sections.each do |section|
          xm.itemref("idref" => "Section#{section.position}.html")
        end
      }
      xm.guide()
    }

    file.close
  end

  def self.generate_toc_ncx(path, ebook_object)
    file = File.new(path + "/toc.ncx", "wb")

    xm = Builder::XmlMarkup.new(:target => file, :indent => 2)
    xm.instruct!
    xm.declare! :DOCTYPE, :ncx, :PUBLIC, "-//NISO//DTD ncx 2005-1//EN", "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd"
    xm.ncx("xmlns" => "http://www.daisy.org/z3986/2005/ncx/", "version" => "2005-1") {
      xm.head {
        xm.meta("content" => "urn:uuid:${ebook_object.id}", "name" => "dtb:uid")
        xm.meta("content" => "2", "name" => "dtb:depth")
        xm.meta("content" => "0", "name" => "dtb:totalPageCount")
        xm.meta("content" => "0", "name" => "dtb:maxPageNumber")
      }
      xm.docTitle {
        xm.text(ebook_object.title)
      }
      xm.navMap {
        ebook_object.sections.each do |section|
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

  def self.generate_mobi(path, slug)
    `#{Rails.root.to_s}/bin/kindlegen #{path} -o #{slug}.mobi`
    "#{Rails.root.to_s}/tmp/#{slug}.mobi"
  end
end
