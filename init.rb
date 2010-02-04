require 'wicked_pdf'
require 'wicked_pdf_tempfile'

unless ActionController::Base.instance_methods.include? "render_with_wicked_pdf"
  require 'pdf_helper'
  ActionController::Base.send :include, PdfHelper
end

unless ActionView::Base.instance_methods.include? "wicked_pdf_stylesheet_link_tag"
  require 'wicked_pdf_helper'
  ActionView::Base.send :include, WickedPdfHelper
end

Mime::Type.register 'application/pdf', :pdf
