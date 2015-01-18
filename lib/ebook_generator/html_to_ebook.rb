require 'nokogiri'

class HtmlToEbook

  attr_accessor :set_title, :save

  def initialize(file, language = 'en')
    @ebook = Ebook.new
    @ebook.language = language
    f = File.open(file)
    @html = Nokogiri::HTML(f)
    f.close
  end

  def set_title(title_tag = "title")
    title = @html.at_css(title_tag).content
    @ebook.title = title
  end

  def set_collection(collection_id = 1)
    @ebook.collection_id = collection_id
  end

  def save
    @ebook.save!
  end
end