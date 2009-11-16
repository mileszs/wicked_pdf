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
      w.pdf_from_string(html_string, parse_header_footer(:header => options[:header], :footer => options[:footer]))
    end

    def make_and_send_pdf(pdf_name, options = {})
      send_data(
        make_pdf(options),
        :filename => pdf_name + '.pdf',
        :type => 'application/pdf'
      )
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
end
