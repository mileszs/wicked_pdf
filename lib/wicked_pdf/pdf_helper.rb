class WickedPdf
  module PdfHelper
    def self.included(base)
      # Protect from trying to augment modules that appear
      # as the result of adding other gems.
      return if base != ActionController::Base

      base.class_eval do
        alias_method_chain :render, :wicked_pdf
        alias_method_chain :render_to_string, :wicked_pdf
        after_filter :clean_temp_files
      end
    end

    def self.prepended(base)
      # Protect from trying to augment modules that appear
      # as the result of adding other gems.
      return if base != ActionController::Base

      base.class_eval do
        after_action :clean_temp_files

        alias_method :render_without_wicked_pdf, :render
        alias_method :render_to_string_without_wicked_pdf, :render_to_string

        def render(options = nil, *args, &block)
          render_with_wicked_pdf(options, *args, &block)
        end

        def render_to_string(options = nil, *args, &block)
          render_to_string_with_wicked_pdf(options, *args, &block)
        end
      end
    end

    def wicked_pdf(options = {})
      log_pdf_creation
      options[:basic_auth] = set_basic_auth(options)
      make_and_send_pdf((WickedPdf.config || {}).merge(options))
    end

    def render_with_wicked_pdf(options = nil, *args, &block)
      if options.is_a?(Hash) && options.key?(:pdf)
        wicked_deprecate_render
        wicked_pdf(options)
      else
        render_without_wicked_pdf(options, *args, &block)
      end
    end

    def render_to_string_with_wicked_pdf(options = nil, *args, &block)
      if options.is_a?(Hash) && options.key?(:pdf)
        log_pdf_creation
        wicked_deprecate_render_to_string
        options[:basic_auth] = set_basic_auth(options)
        options.delete :pdf
        make_pdf((WickedPdf.config || {}).merge(options))
      else
        render_to_string_without_wicked_pdf(options, *args, &block)
      end
    end

    private

    def wicked_deprecate_render
      wicked_deprecate "[wicked_pdf]: `\e[033mrender pdf: 'my_pdf'\e[0m` is deprecated and will be removed in wicked_pdf 2.0. Use `\e[032mwicked_pdf filename: 'my_pdf'\e[0m` instead, or omit the `:filename` to use the controller's `action_name` by default."
    end

    def wicked_deprecate_render_to_string
      wicked_deprecate "[wicked_pdf]: `\e[033mrender_to_string pdf: 'my_pdf'\e[0m` is deprecated and will be removed in wicked_pdf 2.0. Use `\e[032mhtml = wicked_pdf(filename: 'my_pdf').join\e[0m` instead."
    end

    def wicked_deprecate(message)
      require 'active_support/deprecation'
      ActiveSupport::Deprecation.warn message
    rescue LoadError
      puts message
    end

    def wicked_filename(options)
      if options[:filename].present?
        options[:filename]
      elsif options[:pdf].present?
        wicked_deprecate_render
        options[:pdf]
      elsif defined?(:action_name)
        action_name
      else
        'pdf'
      end
    end

    def log_pdf_creation
      logger.info '*' * 15 + 'WICKED' + '*' * 15 if logger && logger.respond_to?(:info)
    end

    def set_basic_auth(options = {})
      options[:basic_auth] ||= WickedPdf.config.fetch(:basic_auth) { false }
      return unless options[:basic_auth] && request.env['HTTP_AUTHORIZATION']
      request.env['HTTP_AUTHORIZATION'].split(' ').last
    end

    def clean_temp_files
      return unless defined?(@hf_tempfiles)
      @hf_tempfiles.each(&:close!)
    end

    def make_pdf(options = {})
      render_opts = {
        :template => options[:template],
        :layout => options[:layout],
        :formats => options[:formats],
        :handlers => options[:handlers]
      }
      render_opts[:locals] = options[:locals] if options[:locals]
      render_opts[:file] = options[:file] if options[:file]
      html_string = render_to_string(render_opts)
      options = prerender_header_and_footer(options)
      w = WickedPdf.new(options[:wkhtmltopdf])
      w.pdf_from_string(html_string, options)
    end

    def make_and_send_pdf(options = {})
      options[:wkhtmltopdf] ||= nil
      options[:layout] ||= false
      options[:template] ||= File.join(controller_path, action_name)
      options[:disposition] ||= 'inline'
      if options[:show_as_html]
        render_opts = {
          :template => options[:template],
          :layout => options[:layout],
          :formats => options[:formats],
          :handlers => options[:handlers],
          :content_type => 'text/html'
        }
        render_opts[:locals] = options[:locals] if options[:locals]
        render_opts[:file] = options[:file] if options[:file]
        render(render_opts)
      else
        pdf_content = make_pdf(options)
        pdf_name = wicked_filename(options)
        File.open(options[:save_to_file], 'wb') { |file| file << pdf_content } if options[:save_to_file]
        send_data(pdf_content, :filename => pdf_name + '.pdf', :type => 'application/pdf', :disposition => options[:disposition]) unless options[:save_only]
      end
    end

    # Given an options hash, prerenders content for the header and footer sections
    # to temp files and return a new options hash including the URLs to these files.
    def prerender_header_and_footer(options)
      [:header, :footer].each do |hf|
        next unless options[hf] && options[hf][:html] && options[hf][:html][:template]
        @hf_tempfiles = [] unless defined?(@hf_tempfiles)
        @hf_tempfiles.push(tf = WickedPdfTempfile.new("wicked_#{hf}_pdf.html"))
        options[hf][:html][:layout] ||= options[:layout]
        render_opts = {
          :template => options[hf][:html][:template],
          :layout => options[hf][:html][:layout],
          :formats => options[hf][:html][:formats],
          :handlers => options[hf][:html][:handlers]
        }
        render_opts[:locals] = options[hf][:html][:locals] if options[hf][:html][:locals]
        render_opts[:file] = options[hf][:html][:file] if options[:file]
        tf.write render_to_string(render_opts)
        tf.flush
        options[hf][:html][:url] = "file:///#{tf.path}"
      end
      options
    end
  end
end
