# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wicked_pdf/version'

Gem::Specification.new do |spec|
  spec.name          = "wicked_pdf"
  spec.version       = WickedPdf::VERSION
  spec.authors       = [ 'Miles Z. Sterrett' ]
  spec.email         = 'miles.sterrett@gmail.com'
  spec.summary       = 'PDF generator (from HTML) gem for Ruby on Rails'
  spec.homepage      = 'https://github.com/mileszs/wicked_pdf'
  spec.license       = 'MIT'
  spec.date          = Time.now.strftime('%Y-%m-%d')

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rails'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'mocha'

  spec.description       = <<desc
Wicked PDF uses the shell utility wkhtmltopdf to serve a PDF file to a user from HTML.
In other words, rather than dealing with a PDF generation DSL of some sort,
you simply write an HTML view as you would normally, and let Wicked take care of the hard stuff.
desc
end
