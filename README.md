# EbookGenerator

Rails gem to generate eBooks using the Markdown syntax to format content for sections of the book.

An example of this gem being used can be found at: [ebook-generator.affinity-tech.com](http://ebook-generator.affinity-tech.com)

Requires:
- Postgres with UUID support (uses the id to generate the ebook UUID)
- Rubyzip (to generate the .epub)
- Redcarpet (to render Markdown into HTML)
- Friendly_id (for nice slugs and for naming of generated ebook file)

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

Migrate the db:

`rake db:migrate`

Require the ebook_generator module in your class:

`include 'EbookGenerator'`

Pass the id for the ebook you want to generate:

`EbookGenerator.generate_ebook(ebook.id)`

This will then generate an ebook based on the values in the db in the /tmp folder.

## Feature roadmap

### 0.1.0
- Kindle support
- Tests

### 0.2.0
- Style editing

### 0.3.0
- PDF out

### 0.4.0
- HTML out
- Image support for the front cover

### 0.5.0
- HTML to eBook conversion

### 0.6.0
- User membership to manage books

Publishing support?

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ebook_generator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
