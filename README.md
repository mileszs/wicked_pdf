# Wicked PDF

## A PDF generation plugin for Ruby on Rails

Wicked PDF uses the shell utility [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/) to serve a PDF file to a user from HTML.  In other words, rather than dealing with a PDF generation DSL of some sort, you simply write an HTML view as you would normally, and let Wicked take care of the hard stuff.

_Wicked PDF requires Ruby 1.8.7_

### Installation

First, be sure to install [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/).
Note that versions before 0.9.0 [have problems](http://code.google.com/p/wkhtmltopdf/issues/detail?id=82&q=vodnik) on some machines with reading/writing to streams.
This plugin relies on streams to communicate with wkhtmltopdf.

More information about [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/) could be found [here](http://madalgo.au.dk/~jakobt/wkhtmltopdf-0.9.0_beta2-doc.html).

Next:

    script/plugin install git://github.com/mileszs/wicked_pdf.git
    script/generate wicked_pdf

### Usage

    class ThingsController < ApplicationController
      def show
        respond_to do |format|
          format.html
          format.pdf do
            render :pdf => "file_name",
                   :template => "things/show.pdf.erb", # OPTIONAL
                   :layout => "pdf.html", # OPTIONAL
                   :wkhtmltopdf => '/usr/local/bin/wkhtmltopdf', # OPTIONAL, path to binary
                   :show_as_html => !params[:debug].blank?, #OPTIONAL, maybe you just want to allow debuging in development environment?
                   :margin => {:top => SIZE, #OPTIONAL
                               :bottom  => SIZE, #OPTIONAL
                               :left  => SIZE, #OPTIONAL
                               :right  => SIZE}, #OPTIONAL
                   :orientation => 'Landscape or Portrait', #OPTIONAL, default Portrait
                   :page_size => 'A4, Letter, ...', #OPTIONAL, default A4
                   :proxy => 'TEXT', #OPTIONAL
                   :username => 'TEXT', #OPTIONAL
                   :password => 'TEXT', #OPTIONAL
                   :cover => 'URL', #OPTIONAL
                   :dpi => "dpi", #OPTIONAL
                   :encoding => "TEXT", #OPTIONAL
                   :user_style_sheet => "URL", #OPTIONAL
                   :redirect_delay => NUMBER, #OPTIONAL
                   :zoom => FLOAT, #OPTIONAL
                   :page_offset => NUMBER, #OPTIONAL
                   :book => true,  #OPTIONAL
                   :default_header => true,  #OPTIONAL
                   :disable_javascript => true,  #OPTIONAL
                   :greyscale => true,  #OPTIONAL 
                   :lowquality => true,  #OPTIONAL
                   :enable_plugins => true,  #OPTIONAL
                   :disable_internal_links => true,  #OPTIONAL
                   :disable_external_links => true,  #OPTIONAL
                   :print_media_type => true,  #OPTIONAL
                   :disable_smart_shrinking => true,  #OPTIONAL
                   :use_xserver => true,  #OPTIONAL
                   :no_background => true,  #OPTIONAL
                   :header => {:html => {:template => "public/header.pdf.erb" OR :url => "www.header.bbb"}, #OPTIONAL
                               :center => "TEXT", #OPTIONAL
                               :font_name => "NAME", #OPTIONAL
                               :font_size => SIZE, #OPTIONAL
                               :left => "TEXT", #OPTIONAL
                               :right => "TEXT", #OPTIONAL
                               :spacing => REAL, #OPTIONAL
                               :line => true}, #OPTIONAL
                   :footer => {:html => {:template => "public/header.pdf.erb" OR :url => "www.header.bbb"}, #OPTIONAL
                               :center => "TEXT", #OPTIONAL
                               :font_name => "NAME", #OPTIONAL
                               :font_size => SIZE, #OPTIONAL
                               :left => "TEXT", #OPTIONAL
                               :right => "TEXT", #OPTIONAL
                               :spacing => REAL, #OPTIONAL
                               :line => true}, #OPTIONAL
                   :toc => {:font_name => "NAME", #OPTIONAL
                            :depth => LEVEL, #OPTIONAL
                            :header_text => "TEXT", #OPTIONAL
                            :header_fs => SIZE, #OPTIONAL
                            :l1_font_size => SIZE, #OPTIONAL 
                            :l2_font_size => SIZE, #OPTIONAL 
                            :l3_font_size => SIZE, #OPTIONAL
                            :l4_font_size => SIZE, #OPTIONAL
                            :l5_font_size => SIZE, #OPTIONAL
                            :l6_font_size => SIZE, #OPTIONAL
                            :l7_font_size => SIZE, #OPTIONAL
                            :l1_indentation => NUM, #OPTIONAL
                            :l2_indentation => NUM, #OPTIONAL
                            :l3_indentation => NUM, #OPTIONAL
                            :l4_indentation => NUM, #OPTIONAL
                            :l5_indentation => NUM, #OPTIONAL
                            :l6_indentation => NUM, #OPTIONAL
                            :l7_indentation => NUM, #OPTIONAL
                            :no_dots => true, #OPTIONAL
                            :disable_links => true, #OPTIONAL
                            :disable_back_links => true}, #OPTIONAL
                   :outline => {:outline => true, #OPTIONAL
                                :outline_depth => LEVEL} #OPTIONAL
          end
        end
      end
    end

By default, it will render without a layout (:layout => false) and the template for the current controller and action.

### Styles

You must define absolute path's to CSS files, the best option is to use *wicked_pdf_stylesheet_link_tag* helper.

    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <%= wicked_pdf_stylesheet_link_tag "pdf" -%>
      </head>
      <body>
        <div id="content">
          <%= yield %>
        </div>
      </body>
    </html>

### Configuration

You can put your default configuration, applied to all pdf's at "wicked_pdf.rb" initializer.

### Debugging

Now you can use a debug param on the URL that shows you the content of the pdf in plain html to design it faster.

First of all you must configure the render parameter ":show_as_html" and then just use it like normally but adding "debug=1" as a param:

http://localhost:3001/CONTROLLER/X.pdf?debug=1

### Inspiration

You may have noticed: this plugin is heavily inspired by the PrinceXML plugin [princely](http://github.com/mbleigh/princely/tree/master).  PrinceXML's cost was prohibitive for me. So, with a little help from some friends (thanks [jqr](http://github.com/jqr)), I tracked down wkhtmltopdf, and here we are.

### Awesome Peoples

Also, thanks to [galdomedia](http://github.com/galdomedia) and [jcrisp](http://github.com/jcrisp) and [lleirborras](http://github.com/lleirborras) for all their hard work and patience with my delays in merging in their enhancements.
