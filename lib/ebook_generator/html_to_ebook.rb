require 'nokogiri'

class HtmlToEbook
  def initialize(file)
    @ebook = Ebook.new
    f = File.open(file)
    @html = Nokogiri::HTML(f)
    f.close
  end

  def set_title(title_tag = "title")
    title = @html.css_at(title_tag).content
    @ebook.title = title
  def 

  def save
    @ebook.save
  end
end