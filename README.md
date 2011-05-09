# Wicked PDF

## A PDF generation plugin for Ruby on Rails

Wicked PDF uses the shell utility [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/) to serve a PDF file to a user from HTML.  In other words, rather than dealing with a PDF generation DSL of some sort, you simply write an HTML view as you would normally, and let Wicked take care of the hard stuff.

_Wicked PDF has been verified to work on Ruby 1.8.7 and 1.9.2; Rails 2 and Rails 3_

### Installation

First, be sure to install [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/).
Note that versions before 0.9.0 [have problems](http://code.google.com/p/wkhtmltopdf/issues/detail?id=82&q=vodnik) on some machines with reading/writing to streams.
This plugin relies on streams to communicate with wkhtmltopdf.

More information about [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/) could be found [here](http://madalgo.au.dk/~jakobt/wkhtmltoxdoc/wkhtmltopdf-0.9.9-doc.html).

Next:

    script/plugin install git://github.com/mileszs/wicked_pdf.git
    script/generate wicked_pdf
### Basic Usage

    class ThingsController < ApplicationController
      def show
        respond_to do |format|
          format.html
          format.pdf do
            render :pdf => "file_name"
          end
        end
      end
    end

### Advanced Usage with all available options

    class ThingsController < ApplicationController
      def show
        respond_to do |format|
          format.html
          format.pdf do
            render :pdf                            => 'file_name',
                   :template                       => 'things/show.pdf.erb',
                   :layout                         => 'pdf.html',                   # use 'pdf.html' for a pfd.html.erb file
                   :wkhtmltopdf                    => '/usr/local/bin/wkhtmltopdf', # path to binary
                   :show_as_html                   => params[:debug].present?,      # allow debuging based on url param
                   :orientation                    => 'Landscape',                  # default Portrait
                   :page_size                      => 'A4, Letter, ...',            # default A4
                   :save_to_file                   => Rails.root.join('pdfs', "#{filename}.pdf"),
                   :save_only                      => false,                        # depends on :save_to_file being set first
                   :proxy                          => 'TEXT',
                   :username                       => 'TEXT',
                   :password                       => 'TEXT',
                   :cover                          => 'URL',
                   :dpi                            => 'dpi',
                   :encoding                       => 'TEXT',
                   :user_style_sheet               => 'URL',
                   :redirect_delay                 => NUMBER,
                   :zoom                           => FLOAT,
                   :page_offset                    => NUMBER,
                   :book                           => true,
                   :default_header                 => true,
                   :disable_javascript             => false,
                   :greyscale                      => true,
                   :lowquality                     => true,
                   :enable_plugins                 => true,
                   :disable_internal_links         => true,
                   :disable_external_links         => true,
                   :print_media_type               => true,
                   :disable_smart_shrinking        => true,
                   :use_xserver                    => true,
                   :no_background                  => true,
                   :margin => {:top                => SIZE,                         # default 10 (mm)
                               :bottom             => SIZE,
                               :left               => SIZE,
                               :right              => SIZE},
                   :header => {:html => { :template => 'users/header.pdf.erb', # use :template OR :url
                                          :url      => 'www.example.com',
                                          :locals   => { :foo => @bar }},
                               :center             => 'TEXT',
                               :font_name          => 'NAME',
                               :font_size          => SIZE,
                               :left               => 'TEXT',
                               :right              => 'TEXT',
                               :spacing            => REAL,
                               :line               => true},
                   :footer => {:html => { :template => 'shared/footer.pdf.erb', # use :template OR :url
                                          :url      => 'www.example.com',
                                          :locals   => { :foo => @bar }},
                               :center             => 'TEXT',
                               :font_name          => 'NAME',
                               :font_size          => SIZE,
                               :left               => 'TEXT',
                               :right              => 'TEXT',
                               :spacing            => REAL,
                               :line               => true},
                   :toc    => {:font_name          => "NAME",
                               :depth              => LEVEL,
                               :header_text        => "TEXT",
                               :header_fs          => SIZE,
                               :l1_font_size       => SIZE,
                               :l2_font_size       => SIZE,
                               :l3_font_size       => SIZE,
                               :l4_font_size       => SIZE,
                               :l5_font_size       => SIZE,
                               :l6_font_size       => SIZE,
                               :l7_font_size       => SIZE,
                               :l1_indentation     => NUM,
                               :l2_indentation     => NUM,
                               :l3_indentation     => NUM,
                               :l4_indentation     => NUM,
                               :l5_indentation     => NUM,
                               :l6_indentation     => NUM,
                               :l7_indentation     => NUM,
                               :no_dots            => true,
                               :disable_links      => true,
                               :disable_back_links => true},
                   :outline => {:outline           => true,
                                :outline_depth     => LEVEL}
          end
        end
      end
    end

By default, it will render without a layout (:layout => false) and the template for the current controller and action.

### Super Advanced Usage ###

If you need to just create a pdf and not display it:

    # create a pdf from a string
    pdf = WickedPdf.new.pdf_from_string('<h1>Hello There!</h1>')
		
    # or from your controller, using views & templates and all wicked_pdf options as normal
    pdf = render_to_string :pdf => "some_file_name"
		
    # then save to a file
    save_path = Rails.root.join('pdfs','filename.pdf')
    File.open(save_path, 'wb') do |file|
      file << pdf
    end

If you need to display utf encoded characters, add this to your pdf views or layouts:

    <meta http-equiv="content-type" content="text/html; charset=utf-8" />

### Styles

You must define absolute path's to CSS files, images, and javascripts; the best option is to use the *wicked_pdf_stylesheet_link_tag*, *wicked_pdf_image_tag*, and *wicked_pdf_javascript_include_tag* helpers.

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
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

### Page Numbering

A bit of javascript can help you number your pages, create a template or header/footer file with this:

    <html>
      <head>
        <script>
          function number_pages() {
            var vars={};
            var x=document.location.search.substring(1).split('&');
            for(var i in x) {var z=x[i].split('=',2);vars[z[0]] = unescape(z[1]);}
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

Anything with a class listed in "var x" above will be auto-filled at render time.

If you do not have explicit page breaks (and therefore do not have any "page" class), you can also use wkhtmltopdf's built in page number generation by setting one of the headers to "[page]":

    render :pdf => 'filename', :header => { :right => '[page] of [topage]' }

### Configuration

You can put your default configuration, applied to all pdf's at "wicked_pdf.rb" initializer.

### Further Reading

Andreas Happe's post [Generating PDFs from Ruby on Rails](http://snikt.net/index.php/2010/03/03/generating-pdfs-from-ruby-on-rails)

### Debugging

Now you can use a debug param on the URL that shows you the content of the pdf in plain html to design it faster.

First of all you must configure the render parameter ":show_as_html => params[:debug]" and then just use it like normally but adding "debug=1" as a param:

http://localhost:3001/CONTROLLER/X.pdf?debug=1

However, the wicked_pdf_* helpers will use file:// paths for assets when using :show_as_html, and your browser's cross-domain safety feature will kick in, and not render them. To get around this, you can load your assets like so in your templates:

    <%= params[:debug].present? ? image_tag('foo') : wicked_pdf_image_tag('foo') %>

### Inspiration

You may have noticed: this plugin is heavily inspired by the PrinceXML plugin [princely](http://github.com/mbleigh/princely/tree/master).  PrinceXML's cost was prohibitive for me. So, with a little help from some friends (thanks [jqr](http://github.com/jqr)), I tracked down wkhtmltopdf, and here we are.

### Awesome Peoples

Also, thanks to [unixmonkey](https://github.com/Unixmonkey), [galdomedia](http://github.com/galdomedia), [jcrisp](http://github.com/jcrisp), [lleirborras](http://github.com/lleirborras), [tiennou](http://github.com/tiennou), and everyone else for all their hard work and patience with my delays in merging in their enhancements.
