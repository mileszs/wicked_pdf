require 'wicked_pdf'
require 'pdf_helper'
 
Mime::Type.register 'application/pdf', :pdf
 
ActionController::Base.send(:include, PdfHelper)
