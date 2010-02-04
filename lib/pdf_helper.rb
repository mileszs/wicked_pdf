module PdfHelper
  require 'wicked_pdf'

  def self.included(base)
    base.class_eval do
      alias_method_chain :render, :wicked_pdf
    end
  end

  def render_with_wicked_pdf(options = nil, *args, &block)
    if options.is_a?(Hash) && options.has_key?(:pdf)
      logger.info '*'*15 + 'WICKED' + '*'*15
      make_and_send_pdf(options.delete(:pdf), (WICKED_PDF.blank? ? {} : WICKED_PDF).merge(options))
    else
      render_without_wicked_pdf(options, *args, &block)
    end
  end

  def parse_options opts
    "#{parse_header_footer(:header => opts.delete(:header), :footer => opts.delete(:footer), :layout => opts[:layout])} " + \
    "#{parse_toc(opts.delete(:toc))} #{parse_outline(opts.delete(:outline))} #{parse_margins(opts.delete(:margin))} #{parse_others(opts)} "
  end

  private
    def make_pdf(options = {})
      html_string = render_to_string(:template => options[:template], :layout => options[:layout])
      w = WickedPdf.new(options[:wkhtmltopdf])
      w.pdf_from_string(html_string, parse_options(options))
    end

    def make_and_send_pdf(pdf_name, options = {})
      options[:wkhtmltopdf] ||= nil
      options[:layout] ||= false
      options[:template] ||= File.join(controller_path, action_name)

      if options[:show_as_html]
        render :text => render_to_string(:template => options[:template], :layout => options[:layout])
      else
        send_data(make_pdf(options), :filename => pdf_name + '.pdf', :type => 'application/pdf')
      end
    end

    def make_option name, value, type=:string
      "--#{name.gsub('_', '-')} " + case type
        when :boolean: ""
        when :numeric: value.to_s
        else "'#{value}'"
      end + " "
    end

    def make_options opts, names, prefix="", type=:string
      names.collect {|o| make_option("#{prefix.blank? ? "" : prefix + "-"}#{o.to_s}", opts[o], type) unless opts[o].blank?}.join
    end

    def parse_header_footer opts
      r=""
      [:header, :footer].collect do |hf| 
        unless opts[hf].blank?
          opt_hf = opts[hf]
          r += make_options(opt_hf, [:center, :font_name, :left, :right], "#{hf.to_s}")
          r += make_options(opt_hf, [:font_size, :spacing], "#{hf.to_s}", :numeric)
          r += make_options(opt_hf, [:line], "#{hf.to_s}", :boolean)
          unless opt_hf[:html].blank?
            r += make_option("#{hf.to_s}-html", opt_hf[:html][:url]) unless opt_hf[:html][:url].blank?
            WickedPdfTempfile.open("wicked_pdf.html") do |f|
              f << render_to_string(:template => opt_hf[:html][:template], :layout => opts[:layout])
              r += make_option("#{hf.to_s}-html", "file://#{f.path}")
            end unless opt_hf[:html][:template].blank?
          end
        end
      end unless opts.blank?
      r
    end

    def parse_toc opts
      unless opts.blank?
        r = make_options(opts, [:font_name, :header_text], "toc")
        r += make_options(opts, [:depth, :header_fs, :l1_font_size, :l2_font_size, :l3_font_size, :l4_font_size, :l5_font_size, :l6_font_size, :l7_font_size, :l1_indentation, :l2_indentation, :l3_indentation, :l4_indentation, :l5_indentation, :l6_indentation, :l7_indentation], "toc", :numeric)
        r + make_options(opts, [:no_dots, :disable_links, :disable_back_links], "toc", :boolean)
      end
    end

    def parse_outline opts
      unless opts.blank?
        r = make_options(opts, [:outline], "", :boolean)
        r + make_options(opts, [:outline_depth], "", :numeric)
      end
    end

    def parse_margins opts
      make_options(opts, [:top, :bottom, :left, :right], "margin", :numeric) unless opts.blank?
    end
    
    def parse_others opts
      unless opts.blank? 
        r = make_options(opts, [:orientation, :page_size, :proxy, :username, :password, :cover, :dpi, :encoding, :user_style_sheet])
        r += make_options(opts, [:redirect_delay, :zoom, :page_offset], "", :numeric)
        r + make_options(opts, [:book, :default_header, :disable_javascript, :greyscale, :lowquality, :enable_plugins, :disable_internal_links, :disable_external_links, :print_media_type, :disable_smart_shrinking, :use_xserver, :no_background], "", :boolean)
      end
    end
end
