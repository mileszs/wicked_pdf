# Wicked PDF

## A PDF generation plugin for Ruby on Rails

Wicked PDF uses the shell utility [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/) to serve a PDF file to a user from HTML.  In other words, rather than dealing with a PDF generation DSL of some sort, you simply write an HTML view as you would normally, and let Wicked take care of the hard stuff.

### Installation

First, be sure to install [wkhtmltopdf](http://code.google.com/p/wkhtmltopdf/).

Next:

    script/plugin install git://github.com/mileszs/wicked_pdf.git

### Usage

    class ThingsController < ApplicationController
      def show
        respond_to do |format|
          format.html
          format.pdf do
            render :pdf => "file_name", 
                   :template => "things/show.pdf.erb", # OPTIONAL
                   :layout => "pdf.html", # OPTIONAL
                   :wkhtmltopdf => '/usr/local/bin/wkhtmltopdf' # OPTIONAL, path to binary
          end
        end
      end
    end

By default, it will render without a layout (:layout => false) and the template for the current controller and action.  (So, the template line in the above code is actually unnecessary.)

### Inspiration

You may have noticed: this plugin is heavily inspired by the PrinceXML plugin [princely](http://github.com/mbleigh/princely/tree/master).  PrinceXML's cost was prohibitive for me. So, with a little help from some friends (thanks [jqr](http://github.com/jqr)), I tracked down wkhtmltopdf, and here we are.
