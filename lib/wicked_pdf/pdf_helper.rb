class WickedPdf
  module PdfHelper
    module Prependable
      def render_to_string(options = nil, *args, &block)
        if options.is_a?(Hash) && options.key?(:pdf)
          WickedPdf::Renderer.new(self).render(options)
        else
          super
        end
      end
    end

    module Includable
      def self.included(base)
        base.class_eval do
          alias_method_chain :render, :wicked_pdf
          alias_method_chain :render_to_string, :wicked_pdf
        end
      end

      def render_with_wicked_pdf(options = nil, *args, &block)
        if options.is_a?(Hash) && options.key?(:pdf)
          WickedPdf::Renderer.new(self).render(options)
        else
          # support alias_method_chain (module included)
          render_without_wicked_pdf(options, *args, &block)
        end
      end

      def render_to_string_with_wicked_pdf(options = nil, *args, &block)
        if options.is_a?(Hash) && options.key?(:pdf)
          WickedPdf::Renderer.new(self).render_to_string(options)
        else
          # support alias_method_chain (module included)
          render_to_string_without_wicked_pdf(options, *args, &block)
        end
      end
    end

    def self.included(base)
      # Protect from trying to augment modules that appear
      # as the result of adding other gems.
      return if base != ActionController::Base

      base.send :include, Includable
    end

    def self.prepended(base)
      # Protect from trying to augment modules that appear
      # as the result of adding other gems.
      return if base != ActionController::Base

      base.send :prepend, Prependable
    end
  end
end