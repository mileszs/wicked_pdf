module WickedPdfHelper
  def self.root_path
    String === Rails.root ? Pathname.new(Rails.root) : Rails.root
  end

  def self.add_extension(filename, extension)
    (File.extname(filename.to_s)[1..-1] == extension) ? filename : "#{filename}.#{extension}"
  end

  def wicked_pdf_stylesheet_link_tag(*sources)
    css_dir = WickedPdfHelper.root_path.join('public', 'stylesheets')
    css_text = sources.collect { |source|
      source = WickedPdfHelper.add_extension(source, 'css')
      "<style type='text/css'>#{File.read(css_dir.join(source))}</style>"
    }.join("\n")
    css_text.respond_to?(:html_safe) ? css_text.html_safe : css_text
  end

  def wicked_pdf_image_tag(img, options={})
    image_tag "file:///#{WickedPdfHelper.root_path.join('public', 'images', img)}", options
  end

  def wicked_pdf_javascript_src_tag(jsfile, options={})
    jsfile = WickedPdfHelper.add_extension(jsfile, 'js')
    javascript_src_tag "file:///#{WickedPdfHelper.root_path.join('public', 'javascripts', jsfile)}", options
  end

  def wicked_pdf_javascript_include_tag(*sources)
    js_text = sources.collect{ |source| wicked_pdf_javascript_src_tag(source, {}) }.join("\n")
    js_text.respond_to?(:html_safe) ? js_text.html_safe : js_text
  end

  module Assets
    def wicked_pdf_stylesheet_link_tag(*sources)
      sources.collect { |source|
        source = WickedPdfHelper.add_extension(source, 'css')
        "<style type='text/css'>#{read_asset(source)}</style>"
      }.join("\n").html_safe
    end

    def wicked_pdf_image_tag(img, options={})
      image_tag "file:///#{asset_pathname(img).to_s}", options
    end

    def wicked_pdf_javascript_src_tag(jsfile, options={})
      jsfile = WickedPdfHelper.add_extension(jsfile, 'js')
      javascript_include_tag "file:///#{asset_pathname(jsfile).to_s}", options
    end

    def wicked_pdf_javascript_include_tag(*sources)
      sources.collect { |source|
        source = WickedPdfHelper.add_extension(source, 'js')
        "<script type='text/javascript'>#{read_asset(source)}</script>"
      }.join("\n").html_safe
    end

    private

    # borrowed from actionpack/lib/action_view/helpers/asset_url_helper.rb
    URI_REGEXP = %r{^[-a-z]+://|^(?:cid|data):|^//}

    def asset_pathname(source)
      if Rails.configuration.assets.compile == false
        if asset_path(source) =~ URI_REGEXP
          # asset_path returns an absolute URL using asset_host if asset_host is set
          asset_path(source)
        else
          File.join(Rails.public_path, asset_path(source).sub(/\A#{Rails.application.config.action_controller.relative_url_root}/, ''))
        end
      else
        Rails.application.assets.find_asset(source).pathname
      end
    end

    def read_asset(source)
      if Rails.configuration.assets.compile == false
        if asset_path(source) =~ URI_REGEXP
          require 'open-uri'
          asset = open(asset_pathname(source), 'r:UTF-8') {|f| f.read }
          if WickedPdf.config[:expect_gzipped_remote_assets]
            begin
              gz = Zlib::GzipReader.new(StringIO.new(asset))
              asset = gz.read
            rescue Zlib::GzipFile::Error
            end
          end
          return asset
        else
          IO.read(asset_pathname(source))
        end
      else
        Rails.application.assets.find_asset(source).to_s
      end
    end
  end
end
