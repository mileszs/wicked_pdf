require 'open-uri'

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
    src = "file:///#{WickedPdfHelper.root_path.join('public', 'javascripts', jsfile)}"
    content_tag("script", "", { "type" => Mime::JS, "src" => path_to_javascript(src) }.merge(options))
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
      image_tag wicked_pdf_asset_path(img), options
    end

    def wicked_pdf_javascript_src_tag(jsfile, options={})
      jsfile = WickedPdfHelper.add_extension(jsfile, 'js')
      javascript_include_tag wicked_pdf_asset_path(jsfile), options
    end

    def wicked_pdf_javascript_include_tag(*sources)
      sources.collect { |source|
        source = WickedPdfHelper.add_extension(source, 'js')
        "<script type='text/javascript'>#{read_asset(source)}</script>"
      }.join("\n").html_safe
    end

    def wicked_pdf_asset_path(asset)
      if (pathname = asset_pathname(asset).to_s) =~ URI_REGEXP
        pathname
      else
        "file:///#{pathname}"
      end
    end

    private

    # borrowed from actionpack/lib/action_view/helpers/asset_url_helper.rb
    URI_REGEXP = %r{^[-a-z]+://|^(?:cid|data):|^//}

    def asset_pathname(source)
      if precompiled_asset?(source)
        if (pathname = set_protocol(asset_path(source))) =~ URI_REGEXP
          # asset_path returns an absolute URL using asset_host if asset_host is set
          pathname
        else
          File.join(Rails.public_path, asset_path(source).sub(/\A#{Rails.application.config.action_controller.relative_url_root}/, ''))
        end
      else
        Rails.application.assets.find_asset(source).pathname
      end
    end

    #will prepend a http or default_protocol to a protocol realtive URL
    def set_protocol(source)
      protocol = WickedPdf.config[:default_protocol] || "http"
      source = [protocol, ":", source].join if source[0,2] == "//"
      return source
    end

    def precompiled_asset?(source)
      Rails.configuration.assets.compile == false || source.to_s[0] == '/'
    end

    def read_asset(source)
      if precompiled_asset?(source) 
        if set_protocol(asset_path(source)) =~ URI_REGEXP
          read_from_uri(source)
        else
          IO.read(asset_pathname(source))
        end
      else
        Rails.application.assets.find_asset(source).to_s
      end
    end

    def read_from_uri(source)
      encoding = ':UTF-8' if RUBY_VERSION > '1.8'
      asset = open(asset_pathname(source), "r#{encoding}") {|f| f.read }
      asset = gzip(asset) if WickedPdf.config[:expect_gzipped_remote_assets]
      asset
    end

    def gzip(asset)
      stringified_asset = StringIO.new(asset)
      gzipper = Zlib::GzipReader.new(stringified_asset)
      gzipped_asset = gzipper.read
    rescue Zlib::GzipFile::Error
    end

  end
end
