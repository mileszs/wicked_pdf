module WickedPdfHelper
  def wicked_pdf_stylesheet_link_tag(*sources)
    css_dir = Rails.root.join('public','stylesheets')
    sources.collect { |source|
      "<style type='text/css'>#{File.read(css_dir.join(source+'.css'))}</style>"
    }.join("\n").html_safe
  end

  def wicked_pdf_image_tag(img, options={})
    image_tag "file://#{Rails.root.join('public', 'images', img)}", options
  end

  def wicked_pdf_javascript_src_tag(jsfile, options={})
    javascript_src_tag "file://#{Rails.root.join('public','javascripts',jsfile)}", options
  end

  def wicked_pdf_javascript_include_tag(*sources)
    sources.collect{ |source| wicked_pdf_javascript_src_tag(source, {}) }.join("\n").html_safe
  end
  module Assets
    def wicked_pdf_stylesheet_link_tag(*sources)
      sources.collect { |source|
        "<style type='text/css'>#{Rails.application.assets.find_asset(source+".css")}</style>"
      }.join("\n").html_safe
    end

    def wicked_pdf_image_tag(img, options={})
      asset = Rails.application.assets.find_asset(img)
      image_tag "file://#{asset.pathname.to_s}", options
    end

    def wicked_pdf_javascript_src_tag(jsfile, options={})
      asset = Rails.application.assets.find_asset(jsfile)
      javascript_include_tag "file://#{asset.pathname.to_s}", options
    end

    def wicked_pdf_javascript_include_tag(*sources)
      sources.collect{ |source| "<script type='text/javascript'>#{Rails.application.assets.find_asset(source+".js")}</script>" }.join("\n").html_safe
    end
  end
end
