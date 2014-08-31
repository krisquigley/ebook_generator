require 'spec_helper'

RSpec.describe Ebook, :type => :model do
  describe "generating an ebook" do
    let(:path) { "#{Rails.root.to_s}/tmp" }

    before(:all) do
      ebook = FactoryGirl.create(:ebook_with_sections)
      file = EbookGenerator.generate_ebook(ebook)
      path = "#{Rails.root.to_s}/tmp"
      unzip_file(file, path)
    end

    it "should have a mimetype file" do
      expect(File.exist?("#{path}/mimetype")).to be_truthy
    end

    it "should have a container.xml file" do
      expect(File.exist?("#{path}/META-INF/container.xml")).to be_truthy
    end

    it "should have 15 sections" do
      expect(File.exist?("#{path}/OEBPS/Text/Section#{rand(15)}.html")).to be_truthy
    end

    it "should have a content.opf file" do
      expect(File.exist?("#{path}/OEBPS/content.opf")).to be_truthy
    end

    it "should have toc.ncx file" do
      expect(File.exist?("#{path}/OEBPS/toc.ncx")).to be_truthy
    end
  end

  describe "converting markdown to HTML" do
    let(:markdown) { "- Hello" }

    it "should return HTML" do
      expect(EbookGenerator.convert_to_html(markdown)).to eq("<ul>\n<li>Hello</li>\n</ul>\n")
    end
  end

  describe "generating an ebook" do
    let(:subject) {
      title = Faker::Lorem.sentence(5)
      slug = title.gsub(' ', '-')

      ebook = FactoryGirl.create(:ebook_with_sections, :title => title, :slug => slug)
      EbookGenerator.generate_ebook(ebook)
    }

    it "should generate the file" do
      expect(File.exist?(subject)).to be_truthy
    end
  end
end
