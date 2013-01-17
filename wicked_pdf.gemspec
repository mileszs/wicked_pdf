# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'wicked_pdf_version'

Gem::Specification.new do |s|
  s.name              = "wicked_pdf"
  s.version           = WickedPdf::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "PDF generator (from HTML) gem for Ruby on Rails"
  s.homepage          = "https://github.com/mileszs/wicked_pdf"
  s.email             = "miles.sterrett@gmail.com"
  s.authors           = [ "Miles Z. Sterret" ]

  s.files             = %w( README.md Rakefile MIT-LICENSE )
  s.files            += Dir.glob("{lib,generators,test}/**/*")
  s.test_files        = Dir.glob("test/**/*")
  s.require_paths     = ['lib']

  s.add_dependency('rails')
  s.add_development_dependency('rake')
  s.add_development_dependency('sqlite3')

  s.description       = <<desc
Wicked PDF uses the shell utility wkhtmltopdf to serve a PDF file to a user from HTML.
In other words, rather than dealing with a PDF generation DSL of some sort,
you simply write an HTML view as you would normally, and let Wicked take care of the hard stuff.
desc
end
