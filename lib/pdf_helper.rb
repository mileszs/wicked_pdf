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
        send_data(
          make_pdf(options),
          :filename => pdf_name + '.pdf',
          :type => 'application/pdf'
        )
      end
    end

    def parse_options opts
      "#{parse_header_footer(:header => opts.delete(:header), :footer => opts.delete(:footer), :layout => opts[:layout])} \
       #{parse_toc(opts.delete(:toc))} \
       #{parse_outline(opts.delete(:outline))} \
       #{parse_margins(opts.delete(:margin))} \
       #{parse_others(opts)}"
    end

    def parse_header_footer opts
      r=""
      [:header, :footer].collect do |hf| 
        unless opts[hf].blank?
          r += [:center, :font_name, :left, :right].collect do |o|
            "--#{hf.to_s}-#{o.to_s.gsub('_', '-')} '#{opts[hf][o]} '" unless opts[hf][o].blank?
          end.join
          r += [:font_size, :spacing].collect do |o|
            "--#{hf.to_s}-#{o.to_s.gsub('_', '-')} #{opts[hf][o]} " unless opts[hf][o].blank?
          end.join
          r += "--#{hf.to_s}-line " unless opts[hf][:line].blank?
          unless opts[hf][:html].blank?
            r += "--#{hf.to_s}-html '#{opts[hf][:html][:url]}' " unless opts[hf][:html][:url].blank?
            unless opts[hf][:html][:template].blank?
              Tempfile.open("pdf.html") do |f|
                p f.path
                f << render_to_string(:template => opts[hf][:html][:template], :layout => opts[:layout])
                r += "--#{hf.to_s}-html 'file://#{f.path}' "
              end
            end
          end
        end
      end unless opts.blank?
      r
    end

    def parse_toc opts
      unless opts.blank?
        r=""
        r += [:font_name, :header_text].collect do |o|
          "--toc-#{o.to_s.gsub('_', '-')} '#{opts[o]}' " unless opts[o].blank?
        end.join
        r += [:depth, :header_fs, :l1_font_size, :l2_font_size, :l3_font_size, :l4_font_size, :l5_font_size, :l6_font_size, :l7_font_size, :l1_indentation, :l2_indentation, :l3_indentation, :l4_indentation, :l5_indentation, :l6_indentation, :l7_indentation].collect do |o|
          "--toc-#{o.to_s.gsub('_', '-')} #{opts[o]} " unless opts[o].blank?
        end.join
        r += [:no_dots, :disable_links, :disable_back_links].collect do |o|
          "--toc-#{o.to_s.gsub('_', '-')} " unless opts[o].blank?
        end.join
        r
      end
    end

    def parse_outline opts
      unless opts.blank?
        r=""
        r += "--outline " unless opts[:outline].blank?
        r += "--outline-depth '#{opts[:outline_depth]}' " unless opts[:outline_depth].blank?
        r
      end
    end

    def parse_margins opts
      unless opts.blank? 
        r=""
        r += "--margin-top #{opts[:top]} " unless opts[:top].blank?
        r += "--margin-bottom #{opts[:bottom]} " unless opts[:bottom].blank?
        r += "--margin-left #{opts[:left]} " unless opts[:left].blank?
        r += "--margin-right #{opts[:right]} " unless opts[:right].blank?
        r
      end
    end
    
    def parse_others opts
      unless opts.blank? 
        r=""
        r += [:orientation, :page_size, :proxy, :username, :password, :cover, :dpi, :encoding, :user_style_sheet].collect do |o|
          "--#{o.to_s.gsub('_', '-')} '#{opts[o]}' " unless opts[o].blank?
        end.join
        r += [:redirect_delay, :zoom, :page_offset].collect do |o|
          "--#{o.to_s.gsub('_', '-')} #{opts[o]} " unless opts[o].blank?
        end.join
        r += [:book, :default_header, :toc, :disable_javascript, :greyscale, :lowquality, :enable_plugins, :disable_internal_links, :disable_external_links, :print_media_type, :disable_smart_shrinking, :use_xserver, :no_background].collect do |o|
          "--#{o.to_s.gsub('_', '-')} " unless opts[o].blank?
        end.join
        r
      end
    end
end
