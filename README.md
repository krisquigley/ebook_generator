# EbookGenerator

Rails gem to generate eBooks using the Markdown syntax to format content for sections of the book.

An example of this gem being used can be found at: [dskri.be](http://dskri.be)

Requires:
- Rails 4
- Rubyzip (to generate the .epub)
- Redcarpet (to render Markdown into HTML)
- Kindlegen (to generate .mobi files)

## Installation

Add this line to your application's Gemfile:

    gem 'ebook_generator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ebook_generator

## Usage

Generate the tables needed to process the ebooks:
`rails generate ebook_generator`

Migrate the database:
`rake db:migrate`

Pass the ebook object you want to generate:
`EbookGenerator.generate_ebook(ebook_object)`

This will then generate an ePub based on the values in the db and output to the /tmp folder.

For a Kindle mobi file then pass in `kindle` as the second argument:
`EbookGenerator.generate_ebook(ebook_object, 'kindle')`

To enable the generation of Kindle mobi files then you will first need to download the [kindlegen](http://www.amazon.com/gp/feature.html?docId=1000765211)
command line tool from Amazon and put it in your apps `/bin` directory.

## Feature roadmap

### 1.1.0
- Style editing

### 1.2.0
- PDF out

### 1.3.0
- HTML out
- Image support for the front cover

### 1.4.0
- HTML to eBook conversion

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ebook_generator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
