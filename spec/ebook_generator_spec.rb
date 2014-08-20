require 'spec_helper'
require 'fakefs/spec_helpers'


describe "create directories" do
  subject(:generator) { EbookGenerator }
  include FakeFS::SpecHelpers::All

  before(:each) do
    EbookGenerator.make_dirs(["directory","directory2"])
  end

  it "should exist" do
    expect(File).to exist("directory")
  end

  it "should not exist" do
    expect(File).to_not exist("directory3")
  end

  it "should be writable" do
    expect(File.stat("directory").writable?).to eq true
  end

end


describe "generate container file" do
  include FakeFS::SpecHelpers::All
  subject(:generator) { EbookGenerator }
  let(:file) { "container.xml" }

  before(:each) do
    EbookGenerator.generate_container("/")
  end

  it "should create a file" do
    expect(File).to exist(file)
  end

  it "should contain xml" do
    expect(File.read(file)).to match(/<?xml/)
  end
end

describe "generate mimetype" do
  include FakeFS::SpecHelpers::All
  subject(:generator) { EbookGenerator }
  let(:file) { "mimetype" }

  before(:each) do
    EbookGenerator.generate_mimetype(file)
  end

  it "should create a file" do
    expect(File).to exist(file)
  end

  it "should contain the mimetype content" do
    expect(File.read(file)).to eq("application/epub+zip")
  end
end

describe "convert HTML to markdown" do
  subject(:generator) { EbookGenerator }
  let(:markdown) { "- Hello" }

  it "should be in HTML" do
    expect(EbookGenerator.convert_to_html(markdown)).to eq("<ul>\n<li>Hello</li>\n</ul>\n")
  end
end

describe "generating sections" do
#  include FakeFS::SpecHelpers::All
#  subject(:generator) { EbookGenerator }



end

describe "generate content opf file" do
end

describe "generate toc.ncx" do
end

describe "check permissions" do

end

describe "zipping of directory" do

end

describe "removing of directories" do

end
