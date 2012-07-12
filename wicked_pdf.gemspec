Gem::Specification.new do |s|
  s.name              = "wicked_pdf_rails_2"
  s.version           = "0.7.9.3"
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "PDF generator (from HTML) plugin for Ruby on Rails"
  s.homepage          = "https://github.com/d3vkit/wicked_pdf"
  s.email             = "miles.sterrett@gmail.com"
  s.authors           = [ "Miles Z. Sterret" ]

  s.files             = %w( README.md Rakefile MIT-LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("test/**/*")

  s.description       = <<desc
This is a fork of the wicked_pdf gem which allows Rails < 2.3.4 to run. Basically no really big
changes, so I am leaving most of this the same, and hopefully it will be pulled into the master.

Wicked PDF uses the shell utility wkhtmltopdf to serve a PDF file to a user from HTML.
In other words, rather than dealing with a PDF generation DSL of some sort,
you simply write an HTML view as you would normally, and let Wicked take care of the hard stuff.
desc
end
