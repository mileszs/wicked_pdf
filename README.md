# Wicked PDF [![Gem Version](https://badge.fury.io/rb/wicked_pdf.svg)](http://badge.fury.io/rb/wicked_pdf) [![Build Status](https://github.com/mileszs/wicked_pdf/actions/workflows/ci.yml/badge.svg)](https://github.com/mileszs/wicked_pdf/actions/workflows/ci.yml) [![Code Climate](https://codeclimate.com/github/mileszs/wicked_pdf/badges/gpa.svg)](https://codeclimate.com/github/mileszs/wicked_pdf) [![Open Source Helpers](https://www.codetriage.com/mileszs/wicked_pdf/badges/users.svg)](https://www.codetriage.com/mileszs/wicked_pdf)

## A PDF generation plugin for Ruby on Rails

Wicked PDF uses the shell utility [wkhtmltopdf](http://wkhtmltopdf.org) to serve a PDF file to a user from HTML.  In other words, rather than dealing with a PDF generation DSL of some sort, you simply write an HTML view as you would normally, then let Wicked PDF take care of the hard stuff.

_Wicked PDF has been verified to work on Ruby versions 2.2 through 2.6; Rails 4 through 6.1_

### Installation

Add this to your Gemfile and run `bundle install`:

```ruby
gem 'wicked_pdf'
```

Then create the initializer with

    rails generate wicked_pdf

You may also need to add
```ruby
Mime::Type.register "application/pdf", :pdf
```
to `config/initializers/mime_types.rb` in older versions of Rails.

Because `wicked_pdf` is a wrapper for  [wkhtmltopdf](http://wkhtmltopdf.org/), you'll need to install that, too.

The simplest way to install all of the binaries on most Linux or OSX systems is through the gem [wkhtmltopdf-binary](https://github.com/zakird/wkhtmltopdf_binary_gem). Builds for other systems are available [here](https://wkhtmltopdf.org/downloads.html)
To install that gem, add this:

```ruby
gem 'wkhtmltopdf-binary'
```

To your Gemfile and run `bundle install`.

This gem currently installs version 0.12.x of `wkhtmltopdf`. Some of the options listed below are specific 0.9 or below, and others are for 0.12 and up.

You can see what flags are supported for the current version in [wkhtmltopdf's auto-generated manual](https://wkhtmltopdf.org/usage/wkhtmltopdf.txt)

If your wkhtmltopdf executable is not on your webserver's path, you can configure it in an initializer:

```ruby
WickedPdf.config = {
  exe_path: '/usr/local/bin/wkhtmltopdf',
  enable_local_file_access: true
}
```

For more information about `wkhtmltopdf`, see the project's [homepage](http://wkhtmltopdf.org/).

### Basic Usage
```ruby
class ThingsController < ApplicationController
  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "file_name"   # Excluding ".pdf" extension.
      end
    end
  end
end
```
### Usage Conditions - Important!

The wkhtmltopdf binary is run outside of your Rails application; therefore, your normal layouts will not work. If you plan to use any CSS, JavaScript, or image files, you must modify your layout so that you provide an absolute reference to these files. The best option for Rails without the asset pipeline is to use the `wicked_pdf_stylesheet_link_tag`, `wicked_pdf_image_tag`, and `wicked_pdf_javascript_include_tag` helpers or to go straight to a CDN (Content Delivery Network) for popular libraries such as jQuery.

#### wicked_pdf helpers
```html
<!doctype html>
<html>
  <head>
    <meta charset='utf-8' />
    <%= wicked_pdf_stylesheet_link_tag "pdf" -%>
    <%= wicked_pdf_javascript_include_tag "number_pages" %>
  </head>
  <body onload='number_pages'>
    <div id="header">
      <%= wicked_pdf_image_tag 'mysite.jpg' %>
    </div>
    <div id="content">
      <%= yield %>
    </div>
  </body>
</html>
```
Using wicked_pdf_helpers with asset pipeline raises `Asset names passed to helpers should not include the "/assets/" prefix.` error. To work around this, you can use `wicked_pdf_asset_base64` with the normal Rails helpers, but be aware that this will base64 encode your content and inline it in the page. This is very quick for small assets, but large ones can take a long time.

```html
<!doctype html>
<html>
  <head>
    <meta charset='utf-8' />
    <%= stylesheet_link_tag wicked_pdf_asset_base64("pdf") %>
    <%= javascript_include_tag wicked_pdf_asset_base64("number_pages") %>

  </head>
  <body onload='number_pages'>
    <div id="header">
      <%= image_tag wicked_pdf_asset_base64('mysite.jpg') %>
    </div>
    <div id="content">
      <%= yield %>
    </div>
  </body>
</html>
```

#### Webpacker usage

wicked_pdf supports webpack assets.

- Use `wicked_pdf_stylesheet_pack_tag` for stylesheets
- Use `wicked_pdf_javascript_pack_tag` for javascripts
- Use `wicked_pdf_asset_pack_path` to access an asset directly, for example: `image_tag wicked_pdf_asset_pack_path("media/images/foobar.png")`

#### Asset pipeline usage

It is best to precompile assets used in PDF views. This will help avoid issues when it comes to deploying, as Rails serves asset files differently between development and production (`config.assets.compile = false`), which can make it look like your PDFs work in development, but fail to load assets in production.

    config.assets.precompile += ['blueprint/screen.css', 'pdf.css', 'jquery.ui.datepicker.js', 'pdf.js', ...etc...]

#### CDN reference

In this case, you can use that standard Rails helpers and point to the current CDN for whichever framework you are using. For jQuery, it would look somethng like this, given the current versions at the time of this writing.
```html
<!doctype html>
<html>
  <head>
    <%= javascript_include_tag "http://code.jquery.com/jquery-1.10.0.min.js" %>
    <%= javascript_include_tag "http://code.jquery.com/ui/1.10.3/jquery-ui.min.js" %>
```

### Advanced Usage with all available options

_NOTE: Certain options are only supported in specific versions of wkhtmltopdf._

```ruby
class ThingsController < ApplicationController
  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf:                            'file_name',
               disposition:                    'attachment',                 # default 'inline'
               template:                       'things/show',
               locals:                         {foo: @bar},
               file:                           "#{Rails.root}/files/foo.erb",
               inline:                         '<!doctype html><html><head></head><body>INLINE HTML</body></html>',
               layout:                         'pdf',                        # for a pdf.pdf.erb file
               wkhtmltopdf:                    '/usr/local/bin/wkhtmltopdf', # path to binary
               show_as_html:                   params.key?('debug'),         # allow debugging based on url param
               orientation:                    'Landscape',                  # default Portrait
               page_size:                      'A4, Letter, ...',            # default A4
               page_height:                    NUMBER,
               page_width:                     NUMBER,
               save_to_file:                   Rails.root.join('pdfs', "#{filename}.pdf"),
               save_only:                      false,                        # depends on :save_to_file being set first
               default_protocol:               'http',
               proxy:                          'TEXT',
               basic_auth:                     false                         # when true username & password are automatically sent from session
               username:                       'TEXT',
               password:                       'TEXT',
               title:                          'Alternate Title',            # otherwise first page title is used
               cover:                          'URL, Pathname, or raw HTML string',
               dpi:                            'dpi',
               encoding:                       'TEXT',
               user_style_sheet:               'URL',
               cookie:                         ['_session_id SESSION_ID'], # could be an array or a single string in a 'name value' format
               post:                           ['query QUERY_PARAM'],      # could be an array or a single string in a 'name value' format
               redirect_delay:                 NUMBER,
               javascript_delay:               NUMBER,
               window_status:                  'TEXT',                     # wait to render until some JS sets window.status to the given string
               image_quality:                  NUMBER,
               no_pdf_compression:             true,
               zoom:                           FLOAT,
               page_offset:                    NUMBER,
               book:                           true,
               default_header:                 true,
               disable_javascript:             false,
               grayscale:                      true,
               lowquality:                     true,
               enable_plugins:                 true,
               disable_internal_links:         true,
               disable_external_links:         true,
               keep_relative_links:            true,
               print_media_type:               true,

               # define as true the key 'disable_local_file_access' or 'enable_local_file_access', not both
               disable_local_file_access:      true,
               enable_local_file_access:       false,                     # must be true when using wkhtmltopdf > 0.12.6

               disable_smart_shrinking:        true,
               use_xserver:                    true,
               background:                     false,                     # background needs to be true to enable background colors to render
               no_background:                  true,
               no_stop_slow_scripts:           false,
               viewport_size:                  'TEXT',                    # available only with use_xserver or patched QT
               extra:                          '',                        # directly inserted into the command to wkhtmltopdf
               raise_on_all_errors:            nil,                       # raise error for any stderr output.  Such as missing media, image assets
               log_level:                      'info',                    # Available values: none, error, warn, or info - only available with wkhtmltopdf 0.12.5+
               quiet:                          false,                     # `false` is same as `log_level: 'info'`, `true` is same as `log_level: 'none'`
               outline: {   outline:           true,
                            outline_depth:     LEVEL },
               margin:  {   top:               SIZE,                     # default 10 (mm)
                            bottom:            SIZE,
                            left:              SIZE,
                            right:             SIZE },
               header:  {   html: {            template: 'users/header',          # use :template OR :url
                                               layout:   'pdf_plain',             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
                                               url:      'www.example.com',
                                               locals:   { foo: @bar }},
                            center:            'TEXT',
                            font_name:         'NAME',
                            font_size:         SIZE,
                            left:              'TEXT',
                            right:             'TEXT',
                            spacing:           REAL,
                            line:              true,
                            content:           'HTML CONTENT ALREADY RENDERED'}, # optionally you can pass plain html already rendered (useful if using pdf_from_string)
               footer:  {   html: {   template:'shared/footer',         # use :template OR :url
                                      layout:  'pdf_plain.html',        # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
                                      url:     'www.example.com',
                                      locals:  { foo: @bar }},
                            center:            'TEXT',
                            font_name:         'NAME',
                            font_size:         SIZE,
                            left:              'TEXT',
                            right:             'TEXT',
                            spacing:           REAL,
                            line:              true,
                            content:           'HTML CONTENT ALREADY RENDERED'}, # optionally you can pass plain html already rendered (useful if using pdf_from_string)
               toc:     {   font_name:         "NAME",
                            depth:             LEVEL,
                            header_text:       "TEXT",
                            header_fs:         SIZE,
                            text_size_shrink:  0.8,
                            l1_font_size:      SIZE,
                            l2_font_size:      SIZE,
                            l3_font_size:      SIZE,
                            l4_font_size:      SIZE,
                            l5_font_size:      SIZE,
                            l6_font_size:      SIZE,
                            l7_font_size:      SIZE,
                            level_indentation: NUM,
                            l1_indentation:    NUM,
                            l2_indentation:    NUM,
                            l3_indentation:    NUM,
                            l4_indentation:    NUM,
                            l5_indentation:    NUM,
                            l6_indentation:    NUM,
                            l7_indentation:    NUM,
                            no_dots:           true,
                            disable_dotted_lines:  true,
                            disable_links:     true,
                            disable_toc_links: true,
                            disable_back_links:true,
                            xsl_style_sheet:   'file.xsl'}, # optional XSLT stylesheet to use for styling table of contents
               progress: proc { |output| puts output } # proc called when console output changes
      end
    end
  end
end
```
By default, it will render without a layout (layout: false) and the template for the current controller and action.

#### wkhtmltopdf Binary Options

Some of the options above are being passed to `wkhtmltopdf` binary. They can be used to control the options used in Webkit rendering before generating the PDF.

Examples of those options are:

```ruby
print_media_type: true        # Passes `--print-media-type`
no_background: true           # Passes `--no-background`
```

You can see the complete list of options under "Global Options" in wkhtmltopdf usage [docs](http://wkhtmltopdf.org/usage/wkhtmltopdf.txt).

### Super Advanced Usage ###

If you need to just create a pdf and not display it:
```ruby
# create a pdf from a string
pdf = WickedPdf.new.pdf_from_string('<h1>Hello There!</h1>')

# create a pdf file from a html file without converting it to string
# Path must be absolute path
pdf = WickedPdf.new.pdf_from_html_file('/your/absolute/path/here')

# create a pdf from a URL
pdf = WickedPdf.new.pdf_from_url('https://github.com/mileszs/wicked_pdf')

# create a pdf from string using templates, layouts and content option for header or footer
pdf = WickedPdf.new.pdf_from_string(
  render_to_string('templates/pdf', layout: 'pdfs/layout_pdf.html'),
  footer: {
    content: render_to_string(
  		'templates/footer',
  		layout: 'pdfs/layout_pdf.html'
  	)
  }
)

# It is possible to use footer/header templates without a layout, in that case you need to provide a valid HTML document
pdf = WickedPdf.new.pdf_from_string(
  render_to_string('templates/full_pdf_template'),
  header: {
    content: render_to_string('templates/full_header_template')
  }
)

# or from your controller, using views & templates and all wicked_pdf options as normal
pdf = render_to_string pdf: "some_file_name", template: "templates/pdf", encoding: "UTF-8"

# then save to a file
save_path = Rails.root.join('pdfs','filename.pdf')
File.open(save_path, 'wb') do |file|
  file << pdf
end

# you can also track progress on your PDF generation, such as when using it from within a Resque job
class PdfJob
  def perform
    blk = proc { |output|
      match = output.match(/\[.+\] Page (?<current_page>\d+) of (?<total_pages>\d+)/)
      if match
        current_page = match[:current_page].to_i
        total_pages = match[:total_pages].to_i
        message = "Generated #{current_page} of #{total_pages} pages"
        at current_page, total_pages, message
      end
    }
    WickedPdf.new.pdf_from_string(html, progress: blk)
  end
end
```
If you need to display utf encoded characters, add this to your pdf views or layouts:
```html
<meta charset="utf-8" />
```
If you need to return a PDF in a controller with Rails in API mode:
```ruby
pdf_html = ActionController::Base.new.render_to_string(template: 'controller_name/action_name', layout: 'pdf')
pdf = WickedPdf.new.pdf_from_string(pdf_html)
send_data pdf, filename: 'file.pdf'
```
### Page Breaks

You can control page breaks with CSS.

Add a few styles like this to your stylesheet or page:
```css
div.alwaysbreak { page-break-before: always; }
div.nobreak:before { clear:both; }
div.nobreak { page-break-inside: avoid; }
```

### Page Numbering

A bit of javascript can help you number your pages. Create a template or header/footer file with this:
```html
<html>
  <head>
    <script>
      function number_pages() {
        var vars={};
        var x=document.location.search.substring(1).split('&');
        for(var i in x) {var z=x[i].split('=',2);vars[z[0]] = decodeURIComponent(z[1]);}
        var x=['frompage','topage','page','webpage','section','subsection','subsubsection'];
        for(var i in x) {
          var y = document.getElementsByClassName(x[i]);
          for(var j=0; j<y.length; ++j) y[j].textContent = vars[x[i]];
        }
      }
    </script>
  </head>
  <body onload="number_pages()">
    Page <span class="page"></span> of <span class="topage"></span>
  </body>
</html>
```
Anything with a class listed in "var x" above will be auto-filled at render time.

If you do not have explicit page breaks (and therefore do not have any "page" class), you can also use wkhtmltopdf's built in page number generation by setting one of the headers to "[page]":
```ruby
render pdf: 'filename', header: { right: '[page] of [topage]' }
```
### Configuration

You can put your default configuration, applied to all pdf's at "wicked_pdf.rb" initializer.

### Rack Middleware

If you would like to have WickedPdf automatically generate PDF views for all (or nearly all) pages by appending .pdf to the URL, add the following to your Rails app:
```ruby
# in application.rb (Rails3) or environment.rb (Rails2)
require 'wicked_pdf'
config.middleware.use WickedPdf::Middleware
```
If you want to turn on or off the middleware for certain URLs, use the `:only` or `:except` conditions like so:
```ruby
# conditions can be plain strings or regular expressions, and you can supply only one or an array
config.middleware.use WickedPdf::Middleware, {}, only: '/invoice'
config.middleware.use WickedPdf::Middleware, {}, except: [ %r[^/admin], '/secret', %r[^/people/\d] ]
```
If you use the standard `render pdf: 'some_pdf'` in your app, you will want to exclude those actions from the middleware.


### Include in an email as an attachment

To include a rendered pdf file in an email you can do the following:

```ruby
attachments['attachment.pdf'] = WickedPdf.new.pdf_from_string(
  render_to_string('link_to_view.pdf.erb', layout: 'pdf')
)
```

This will render the pdf to a string and include it in the email. This is very slow so make sure you schedule your email delivery in a job.

### Further Reading

Mike Ackerman's post [How To Create PDFs in Rails](https://www.viget.com/articles/how-to-create-pdfs-in-rails)

Andreas Happe's post [Generating PDFs from Ruby on Rails](http://www.snikt.net/blog/2012/04/26/wicked-pdf/)

JESii's post [WickedPDF, wkhtmltopdf, and Heroku...a tricky combination](http://www.nubyrubyrailstales.com/2013/06/wickedpdf-wkhtmltopdf-and-herokua.html)

Berislav Babic's post [Send PDF attachments from Rails with WickedPdf and ActionMailer](http://berislavbabic.com/send-pdf-attachments-from-rails-with-wickedpdf-and-actionmailer/)

Corsego's 2021 post [Complete guide to generating PDFs with gem wicked_pdf](https://blog.corsego.com/gem-wicked-pdf)

PDFTron's post [How to Generate PDFs With Ruby on Rails](https://www.pdftron.com/blog/rails/how-to-generate-pdf-with-ruby-on-rails/)

StackOverflow [questions with the tag "wicked-pdf"](http://stackoverflow.com/questions/tagged/wicked-pdf)

### Screencasts

* SupeRails Screencast [EN]

[![Ruby on Rails #17 generate, save, send PDFs with gem wicked_pdf](https://i3.ytimg.com/vi/tFvtwEmW-GE/hqdefault.jpg)](https://youtu.be/tFvtwEmW-GE)

* codigofacilito Screencast [ES]

[![Generar PDF con Ruby on Rails - Tutorial](https://i3.ytimg.com/vi/jeWM_gusmJc/hqdefault.jpg)](https://youtu.be/jeWM_gusmJc)

### Debugging

Now you can use a debug param on the URL that shows you the content of the pdf in plain html to design it faster.

First of all you must configure the render parameter `show_as_html: params.key?('debug')` and then just use it like you normally would but add "debug" as a GET param in the URL:

http://localhost:3001/CONTROLLER/X.pdf?debug

However, the wicked_pdf_* helpers will use file:/// paths for assets when using :show_as_html, and your browser's cross-domain safety feature will kick in, and not render them. To get around this, you can load your assets like so in your templates:
```html
<%= params.key?('debug') ? image_tag('foo') : wicked_pdf_image_tag('foo') %>
```

#### Gotchas

If one image from your HTML cannot be found (relative or wrong path for example), others images with right paths **may not** be displayed in the output PDF as well (it seems to be an issue with wkhtmltopdf).

wkhtmltopdf may render at different resolutions on different platforms. For example, Linux prints at 75 dpi (native for WebKit) while on Windows it's at the desktop's DPI (which is normally 96 dpi). [Use `:zoom => 0.78125`](https://github.com/wkhtmltopdf/wkhtmltopdf/issues/2184) (75/96) to match Linux rendering to Windows.

### Security considerations

WickedPdf renders page content on the server by saving HTML and assets to temporary files on disk, then executing `wkhtmltopdf` to convert that HTML to a PDF file.

It is highly recommended if you allow user-generated HTML/CSS/JS to be converted to PDF, you sanitize it first, or at least disallow requesting content from internal IP addresses and hostnames.

For example, these could potentially leak internal AWS metadata:
```html
<iframe src="http://169.254.169.254/latest/meta-data/"></iframe>
<object data="http://169.254.169.254/latest/meta-data/" type="text/html">
```

Thank you to Adam Gold from [Snyk](https://snyk.io) for reporting this.
We are considering adding host allow & block lists and/or potentially HTML element sanitizing.
Please open an issue or PR to help us out with this.

### Inspiration

You may have noticed: this plugin is heavily inspired by the PrinceXML plugin [princely](http://github.com/mbleigh/princely/tree/master).  PrinceXML's cost was prohibitive for me. So, with a little help from some friends (thanks [jqr](http://github.com/jqr)), I tracked down wkhtmltopdf, and here we are.

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the test suite and check the output (`rake`)
4. Add tests for your feature or fix (please)
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request

### Awesome Peoples

Also, thanks to [unixmonkey](https://github.com/Unixmonkey), [galdomedia](http://github.com/galdomedia), [jcrisp](http://github.com/jcrisp), [lleirborras](http://github.com/lleirborras), [tiennou](http://github.com/tiennou), and everyone else for all their hard work and patience with my delays in merging in their enhancements.
