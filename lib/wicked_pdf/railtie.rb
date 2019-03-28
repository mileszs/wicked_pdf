require 'wicked_pdf/pdf_helper'
require 'wicked_pdf/renderer'
require 'wicked_pdf/wicked_pdf_helper'
require 'wicked_pdf/wicked_pdf_helper/assets'

class WickedPdf
  if defined?(Rails.env)

    if Rails::VERSION::MAJOR >= 3

      class WickedRailtie < Rails::Railtie
        initializer 'wicked_pdf.register' do |_app|
          if ActionController::Base.respond_to?(:prepend)
            ActionController::Base.send :prepend, PdfHelper
            ActionController::Renderers.add :pdf do |template, options|
              WickedPdf::Renderer.new(self).render(options.merge(:pdf => template))
            end
          else
            ActionController::Base.send :include, PdfHelper
          end

          if Rails::VERSION::MAJOR == 3
            if Rails::VERSION::MINOR > 0 && Rails.configuration.assets.enabled
              ActionView::Base.send :include, WickedPdfHelper::Assets
            else
              ActionView::Base.send :include, WickedPdfHelper
            end
          else
            ActionView::Base.send :include, WickedPdfHelper::Assets
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