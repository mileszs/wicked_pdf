require 'wicked_pdf/pdf_helper'
require 'wicked_pdf/wicked_pdf_helper'
require 'wicked_pdf/wicked_pdf_helper/assets'

class WickedPdf
  if defined?(Rails.env)

    if Rails::VERSION::MAJOR >= 5

      class WickedRailtie < Rails::Railtie
        initializer 'wicked_pdf.register' do |_app|
          hook = if Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR <= 1
                   :action_controller
                 else
                   :action_controller_base
                 end
          ActiveSupport.on_load(hook) do
            ActionController::Base.send :prepend, PdfHelper
          end
          ActionView::Base.send :include, WickedPdfHelper::Assets
        end
      end

    elsif Rails::VERSION::MAJOR == 4

      class WickedRailtie < Rails::Railtie
        initializer 'wicked_pdf.register' do |_app|
          ActiveSupport.on_load(:action_controller) do
            ActionController::Base.send :include, PdfHelper
          end
          ActionView::Base.send :include, WickedPdfHelper::Assets
        end
      end

    elsif Rails::VERSION::MAJOR == 3

      class WickedRailtie < Rails::Railtie
        initializer 'wicked_pdf.register' do |_app|
          ActiveSupport.on_load(:action_controller) do
            ActionController::Base.send :include, PdfHelper
          end
          if Rails::VERSION::MINOR > 0 && Rails.configuration.assets.enabled
            ActionView::Base.send :include, WickedPdfHelper::Assets
          else
            ActionView::Base.send :include, WickedPdfHelper
          end
        end
      end

    elsif Rails::VERSION::MAJOR == 2

      unless ActionController::Base.instance_methods.include? 'render_with_wicked_pdf'
        ActionController::Base.send :include, PdfHelper
      end
      unless ActionView::Base.instance_methods.include? 'wicked_pdf_stylesheet_link_tag'
        ActionView::Base.send :include, WickedPdfHelper
      end

    end

    if Mime::Type.lookup_by_extension(:pdf).nil?
      Mime::Type.register('application/pdf', :pdf)
    end

  end
end
