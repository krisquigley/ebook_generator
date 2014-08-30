require 'spec_helper'

RSpec.describe Ebook, :type => :model do
  describe "generating an ebook" do
    let(:path) { '/tmp' }
    let(:subject) {
      ebook = FactoryGirl.create(:ebook_with_sections)
      EbookGenerator.generate_ebook(ebook)
    }

    it "should generate the file" do
      expect(File.exist?(subject)).to be_truthy
    end
  end

  describe "generating an ebook" do
    let(:path) { '/tmp' }

    before(:suite) do
      ebook = FactoryGirl.create(:ebook_with_sections)
      EbookGenerator.generate_ebook(ebook)
      unzip_file(subject, path)
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
end
