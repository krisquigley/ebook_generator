RSpec.configure do |config|
  ENV["RAILS_ENV"] = "test"

  require File.expand_path("../dummy/config/environment.rb",  __FILE__)
  require "rails/test_help"
  require 'ebook_generator'

  Rails.backtrace_cleaner.remove_silencers!
end
