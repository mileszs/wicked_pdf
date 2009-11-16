# Wicked PDF

## A PDF generation plugin for Ruby on Rails

Wicked PDF uses the shell utility [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/) to serve a PDF file to a user from HTML.  In other words, rather than dealing with a PDF generation DSL of some sort, you simply write an HTML view as you would normally, and let Wicked take care of the hard stuff.

### Installation

First, be sure to install [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/).
Note that versions before 0.9.0 [have problems](http://code.google.com/p/wkhtmltopdf/issues/detail?id=82&q=vodnik) on some machines with reading/writing to streams.
This plugin relies on streams to communicate with wkhtmltopdf.

Next:

    script/plugin install git://github.com/jcrisp/wicked_pdf.git
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

By default, it will render without a layout (:layout => false) and the template for the current controller and action.  (So, the template line in the above code is actually unnecessary.)

### Inspiration

You may have noticed: this plugin is heavily inspired by the PrinceXML plugin [princely](http://github.com/mbleigh/princely/tree/master).  PrinceXML's cost was prohibitive for me. So, with a little help from some friends (thanks [jqr](http://github.com/jqr)), I tracked down wkhtmltopdf, and here we are.
