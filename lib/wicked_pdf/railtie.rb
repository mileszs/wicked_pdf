require 'wicked_pdf/pdf_helper'
require 'wicked_pdf/wicked_pdf_helper'
require 'wicked_pdf/wicked_pdf_helper/assets'

class WickedPdf
  if defined?(Rails.env)
    class WickedRailtie < Rails::Railtie
      initializer 'wicked_pdf.register', :after => 'remotipart.controller_helper' do |_app|
        ActiveSupport.on_load(:action_controller) do
          if ActionController::Base.respond_to?(:prepend) &&
             Object.method(:new).respond_to?(:super_method)
            ActionController::Base.send :prepend, PdfHelper
          else
            ActionController::Base.send :include, PdfHelper
          end
          ActionView::Base.send :include, WickedPdfHelper::Assets
        end
      end
    end

    if Mime::Type.lookup_by_extension(:pdf).nil?
      Mime::Type.register('application/pdf', :pdf)
    end

  end
end
