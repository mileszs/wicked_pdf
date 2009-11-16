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
      make_and_send_pdf(options.delete(:pdf), options)
    else
      render_without_wicked_pdf(options, *args, &block)
    end
  end

  private
    def make_pdf(options = {})
      options[:wkhtmltopdf] ||= nil
      options[:layout] ||= false
      options[:template] ||= File.join(controller_path, action_name)

      html_string = render_to_string(:template => options[:template], :layout => options[:layout])
      w = WickedPdf.new(options[:wkhtmltopdf])
      w.pdf_from_string(html_string, options(:header => options[:header], :footer => options[:footer], :toc => options[:toc], :outline => options[:outline]))
    end

    def make_and_send_pdf(pdf_name, options = {})
      send_data(
        make_pdf(options),
        :filename => pdf_name + '.pdf',
        :type => 'application/pdf'
      )
    end

    def options opts
      "#{parse_header_footer(:header => opts[:header], :footer => opts[:footer])} #{parse_toc(opts[:toc])} #{parse_outline(opts[:outline])}"
    end

    def parse_header_footer opts
      r=""
      [:header, :footer].collect do |hf| 
        unless opts[hf].blank?
          r += [:center, :font_name, :font_size, :left, :right, :spacing].collect do |o|
            "--#{hf.to_s}-#{o.to_s.gsub('_', '-')} '#{opts[hf][o]}'" unless opts[hf][o].blank?
          end.join(' ')
          r += "--#{hf.to_s}-line " unless opts[hf][:line].blank?
          unless opts[hf][:html].blank?
            r += "--#{hf.to_s}-html '#{opts[hf][:html][:url]}' " unless opts[hf][:html][:url].blank?
            unless opts[hf][:html][:template].blank?
              Tempfile.open("pdf.html") do |f|
                p f.path
                f << render_to_string(opts[hf][:html][:template])
                r += "--#{hf.to_s}-html 'file://#{f.path}' "
              end
            end
          end
        end
      end
      r
    end

    def parse_toc opts
      unless opts.blank?
        r=""
        r += [:font_name, :depth, :header_text, :header_fs, :l1_font_size, :l2_font_size, :l3_font_size, :l4_font_size, :l5_font_size, :l6_font_size, :l7_font_size, :l1_indentation, :l2_indentation, :l3_indentation, :l4_indentation, :l5_indentation, :l6_indentation, :l7_indentation].collect do |o|
          "--toc-#{o.to_s.gsub('_', '-')} '#{opts[o]}'" unless opts[o].blank?
        end.join(' ')
        r += [:no_dots, :disable_links, :disable_back_links].collect do |o|
          "--toc-#{o.to_s.gsub('_', '-')}" unless opts[o].blank?
        end.join(' ')
        r
      end
    end

    def parse_outline opts
      unless opts.blank?
        r=""
        r += "--outline " unless opts[:outline].blank?
        r += "--outline-depth '#{opts[:outline_depth]}'" unless opts[:outline_depth].blank?
        r
      end
    end
end
