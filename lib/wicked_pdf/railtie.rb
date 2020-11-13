require 'wicked_pdf/pdf_helper'
require 'wicked_pdf/wicked_pdf_helper'
require 'wicked_pdf/wicked_pdf_helper/assets'

class WickedPdf
  if defined?(Rails.env)
    class WickedRailtie < Rails::Railtie
      initializer 'wicked_pdf.register', :after => 'remotipart.controller_helper' do |_app|
        ActiveSupport.on_load(:action_controller) do
          ActionController::Base.send :prepend, PdfHelper
          ActionView::Base.send :include, WickedPdfHelper::Assets
        end
      end
    end

    Mime::Type.register('application/pdf', :pdf) if Mime::Type.lookup_by_extension(:pdf).nil?

  end
end
