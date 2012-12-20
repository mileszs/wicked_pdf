module WickedPdfHelper
  def self.root_path
    String === Rails.root ? Pathname.new(Rails.root) : Rails.root
  end

  def wicked_pdf_stylesheet_link_tag(*sources)
    css_dir = WickedPdfHelper.root_path.join('public', 'stylesheets')
    css_text = sources.collect { |source|
      "<style type='text/css'>#{File.read(css_dir.join(source+'.css'))}</style>"
    }.join("\n")
    css_text.respond_to?(:html_safe) ? css_text.html_safe : css_text
  end

  def wicked_pdf_image_tag(img, options={})
    image_tag "file:///#{WickedPdfHelper.root_path.join('public', 'images', img)}", options
  end

  def wicked_pdf_javascript_src_tag(jsfile, options={})
    javascript_src_tag "file:///#{WickedPdfHelper.root_path.join('public', 'javascripts', jsfile)}", options
  end

  def wicked_pdf_javascript_include_tag(*sources)
    js_text = sources.collect{ |source| wicked_pdf_javascript_src_tag(source, {}) }.join("\n")
    js_text.respond_to?(:html_safe) ? js_text.html_safe : js_text
  end

  module Assets
    def wicked_pdf_stylesheet_link_tag(*sources)
      sources.collect { |source|
        "<style type='text/css'>#{read_asset(source+".css")}</style>"
      }.join("\n").html_safe
    end

    def wicked_pdf_image_tag(img, options={})
      image_tag "file:///#{asset_pathname(img).to_s}", options
    end

    def wicked_pdf_javascript_src_tag(jsfile, options={})
      javascript_include_tag "file:///#{asset_pathname(jsfile).to_s}", options
    end

    def wicked_pdf_javascript_include_tag(*sources)
      sources.collect { |source|
        "<script type='text/javascript'>#{read_asset(source+".js")}</script>"
      }.join("\n").html_safe
    end

    private

    def asset_pathname(source)
      if Rails.configuration.assets.compile == false
        if ActionController::Base.asset_host
          # asset_path returns an absolute URL using asset_host if asset_host is set
          asset_path(source)
        else
          File.join(Rails.public_path, asset_path(source))
        end
      else
        Rails.application.assets.find_asset(source).pathname
      end
    end

    def read_asset(source)
      if Rails.configuration.assets.compile == false
        if ActionController::Base.asset_host
          require 'open-uri'
          open(asset_pathname(source), 'r:UTF-8') {|f| f.read }
        else
          IO.read(asset_pathname(source))
        end
      else
        Rails.application.assets.find_asset(source).to_s
      end
    end
  end
end
