module PdfHelper
  require 'wicked_pdf'
  require 'wicked_pdf_tempfile'

  def self.included(base)
    base.class_eval do
      alias_method_chain :render, :wicked_pdf
      alias_method_chain :render_to_string, :wicked_pdf
      after_filter :clean_temp_files
    end
  end

  def render_with_wicked_pdf(options = nil, *args, &block)
    if options.is_a?(Hash) && options.has_key?(:pdf)
      log_pdf_creation
      options[:basic_auth] = set_basic_auth(options)
      make_and_send_pdf(options.delete(:pdf), (WickedPdf.config || {}).merge(options))
    else
      render_without_wicked_pdf(options, *args, &block)
    end
  end

  def render_to_string_with_wicked_pdf(options = nil, *args, &block)
    if options.is_a?(Hash) && options.has_key?(:pdf)
      log_pdf_creation
      options[:basic_auth] = set_basic_auth(options)
      options.delete :pdf
      make_pdf((WickedPdf.config || {}).merge(options))
    else
      render_to_string_without_wicked_pdf(options, *args, &block)
    end
  end

  private

    def log_pdf_creation
      logger.info '*'*15 + 'WICKED' + '*'*15
    end

    def set_basic_auth(options={})
      options[:basic_auth] ||= WickedPdf.config.fetch(:basic_auth){ false }
      if options[:basic_auth] && request.env["HTTP_AUTHORIZATION"]
        request.env["HTTP_AUTHORIZATION"].split(" ").last
      end
    end

    def clean_temp_files
      if defined?(@hf_tempfiles)
        @hf_tempfiles.each { |tf| tf.close! }
      end
    end

    def make_pdf(options = {})
      html_string = render_to_string(:template => options[:template], :layout => options[:layout], :formats => options[:formats], :handlers => options[:handlers])
      options = prerender_header_and_footer(options)
      w = WickedPdf.new(options[:wkhtmltopdf])
      w.pdf_from_string(html_string, options)
    end

    def make_and_send_pdf(pdf_name, options={})
      options[:wkhtmltopdf] ||= nil
      options[:layout]      ||= false
      options[:template]    ||= File.join(controller_path, action_name)
      options[:disposition] ||= "inline"
      if options[:show_as_html]
        render :template => options[:template], :layout => options[:layout], :formats => options[:formats], :handlers => options[:handlers], :content_type => "text/html"
      else
        pdf_content = make_pdf(options)
        File.open(options[:save_to_file], 'wb') {|file| file << pdf_content } if options[:save_to_file]
        send_data(pdf_content, :filename => pdf_name + '.pdf', :type => 'application/pdf', :disposition => options[:disposition]) unless options[:save_only]
      end
    end

    # Given an options hash, prerenders content for the header and footer sections
    # to temp files and return a new options hash including the URLs to these files.
    def prerender_header_and_footer(options)
      [:header, :footer].each do |hf|
        if options[hf] && options[hf][:html] && options[hf][:html][:template]
          @hf_tempfiles = [] if ! defined?(@hf_tempfiles)
          @hf_tempfiles.push( tf=WickedPdfTempfile.new("wicked_#{hf}_pdf.html") )
          options[hf][:html][:layout] ||=  options[:layout]
          tf.write render_to_string(:template => options[hf][:html][:template], :layout => options[hf][:html][:layout], :locals => options[hf][:html][:locals], :formats => options[hf][:html][:formats], :handlers => options[hf][:html][:handlers])
          tf.flush
          options[hf][:html].delete(:template)
          options[hf][:html][:url] = "file://#{tf.path}"
        end
      end
      options
    end
end
