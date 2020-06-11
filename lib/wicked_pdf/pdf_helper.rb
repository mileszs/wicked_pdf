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
      if options.is_a?(Hash) && options.key?(:pdf)
        options[:basic_auth] = set_basic_auth(options)
        make_and_send_pdf(options.delete(:pdf), (WickedPdf.config || {}).merge(options))
      elsif respond_to?(:render_without_wicked_pdf)
        render_without_wicked_pdf(options, *args, &block)
      else
        super(options, *args, &block)
      end
    end

    def render_to_string(options = nil, *args, &block)
      render_to_string_with_wicked_pdf(options, *args, &block)
    end

    def render_with_wicked_pdf(options = nil, *args, &block)
      render(options, *args, &block)
    end

    def render_to_string_with_wicked_pdf(options = nil, *args, &block)
      if options.is_a?(Hash) && options.key?(:pdf)
        options[:basic_auth] = set_basic_auth(options)
        options.delete :pdf
        make_pdf((WickedPdf.config || {}).merge(options))
      elsif respond_to?(:render_to_string_without_wicked_pdf)
        # support alias_method_chain (module included)
        render_to_string_without_wicked_pdf(options, *args, &block)
      else
        # support inheritance (module prepended)
        method(:render_to_string).super_method.call(options, *args, &block)
      end
    end

    private

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
        :handlers => options[:handlers],
        :assigns => options[:assigns]
      }
      render_opts[:inline] = options[:inline] if options[:inline]
      render_opts[:locals] = options[:locals] if options[:locals]
      render_opts[:file] = options[:file] if options[:file]
      html_string = render_to_string(render_opts)
      options = prerender_header_and_footer(options)
      w = WickedPdf.new(options[:wkhtmltopdf])
      w.pdf_from_string(html_string, options)
    end

    def make_and_send_pdf(pdf_name, options = {})
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
          :assigns => options[:assigns],
          :content_type => 'text/html'
        }
        render_opts[:inline] = options[:inline] if options[:inline]
        render_opts[:locals] = options[:locals] if options[:locals]
        render_opts[:file] = options[:file] if options[:file]
        render(render_opts)
      else
        pdf_content = make_pdf(options)
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
          :handlers => options[hf][:html][:handlers],
          :assigns => options[hf][:html][:assigns]
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
