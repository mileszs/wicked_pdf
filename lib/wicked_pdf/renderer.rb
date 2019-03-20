class WickedPdf
  class Renderer
    attr_reader :controller

    delegate :request, :send_data, :controller_path, :action_name, :to => :controller

    def initialize(controller)
      @controller = controller
      @hf_tempfiles = []
    end

    def render(options)
      options[:basic_auth] = set_basic_auth(options)
      make_and_send_pdf(options.delete(:pdf), (WickedPdf.config || {}).merge(options))
    end

    def render_to_string(options)
      options[:basic_auth] = set_basic_auth(options)
      options.delete :pdf
      make_pdf((WickedPdf.config || {}).merge(options))
    end

    private

    def set_basic_auth(options = {})
      options[:basic_auth] ||= WickedPdf.config.fetch(:basic_auth) { false }
      return unless options[:basic_auth] && request.env['HTTP_AUTHORIZATION']
      request.env['HTTP_AUTHORIZATION'].split(' ').last
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
      html_string = controller.render_to_string(render_opts)
      options = prerender_header_and_footer(options)
      w = WickedPdf.new(options[:wkhtmltopdf])
      w.pdf_from_string(html_string, options)
    ensure
      clean_temp_files
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

        path = render_to_tempfile("wicked_#{hf}_pdf.html", render_opts)
        options[hf][:html][:url] = "file:///#{path}"
      end
      options
    end

    def render_to_tempfile(filename, options)
      tf = WickedPdfTempfile.new(filename)
      @hf_tempfiles.push(tf)
      tf.write controller.render_to_string(options)
      tf.flush
      tf.path
    end

    def clean_temp_files
      @hf_tempfiles.each(&:close!)
    end
  end
end
