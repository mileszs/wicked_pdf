class WickedPdf
  module PdfHelper
    def self.included(base)
      # Protect from trying to augment modules that appear
      # as the result of adding other gems.
      return if base != ActionController::Base

      base.class_eval do
        alias_method_chain :render, :wicked_pdf
        alias_method_chain :render_to_string, :wicked_pdf
        if respond_to?(:after_action)
          after_action :clean_temp_files
        else
          after_filter :clean_temp_files
        end
      end
    end

    def self.prepended(base)
      # Protect from trying to augment modules that appear
      # as the result of adding other gems.
      return if base != ActionController::Base

      base.class_eval do
        after_action :clean_temp_files
      end
    end

    def render(options = nil, *args, &block)
      render_with_wicked_pdf(options, *args, &block)
    end

    def render_to_string(options = nil, *args, &block)
      render_to_string_with_wicked_pdf(options, *args, &block)
    end

    def render_with_wicked_pdf(options = nil, *args, &block)
      if options.is_a?(Hash) && options.key?(:pdf)
        WickedPdf::Renderer.new(self).render(options)
      elsif respond_to?(:render_without_wicked_pdf)
        # support alias_method_chain (module included)
        render_without_wicked_pdf(options, *args, &block)
      else
        # support inheritance (module prepended)
        method(:render).super_method.call(options, *args, &block)
      end
    end

    def render_to_string_with_wicked_pdf(options = nil, *args, &block)
      if options.is_a?(Hash) && options.key?(:pdf)
        WickedPdf::Renderer.new(self).render_to_string(options)
      elsif respond_to?(:render_to_string_without_wicked_pdf)
        # support alias_method_chain (module included)
        render_to_string_without_wicked_pdf(options, *args, &block)
      else
        # support inheritance (module prepended)
        method(:render_to_string).super_method.call(options, *args, &block)
      end
    end

    def prerender_header_and_footer(options)
      WickedPdf::Renderer.new(self).prerender_header_and_footer(options)
    end
  end
end
