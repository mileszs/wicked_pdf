require 'pdf_helper'
require 'wicked_pdf_helper'

if defined?(Rails)

  if Rails::VERSION::MAJOR == 4

    class WickedRailtie < Rails::Railtie
      initializer "wicked_pdf.register" do |app|
        ActionController::Base.send :include, PdfHelper
        ActionView::Base.send :include, WickedPdfHelper::Assets
      end
    end

  elsif Rails::VERSION::MAJOR == 2

    unless ActionController::Base.instance_methods.include? "render_with_wicked_pdf"
      ActionController::Base.send :include, PdfHelper
    end
    unless ActionView::Base.instance_methods.include? "wicked_pdf_stylesheet_link_tag"
      ActionView::Base.send :include, WickedPdfHelper
    end
    
  else

    class WickedRailtie < Rails::Railtie
      initializer "wicked_pdf.register" do |app|
        ActionController::Base.send :include, PdfHelper
        if Rails::VERSION::MINOR > 0 && Rails.configuration.assets.enabled
          ActionView::Base.send :include, WickedPdfHelper::Assets
        else
          ActionView::Base.send :include, WickedPdfHelper
        end
      end
    end

  end
  
  if Mime::Type.lookup_by_extension(:pdf).nil?
    Mime::Type.register('application/pdf', :pdf)
  end
  
end
