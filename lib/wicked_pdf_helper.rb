module WickedPdfHelper
  def wicked_pdf_stylesheet_link_tag(*sources)
    options = sources.extract_options!
    if request.try(:format).to_s == 'application/pdf'
      css_dir = Rails.root.join('public','stylesheets')
      refer_only = options.delete(:refer_only)
      sources.collect { |source|
        source.sub!(/\.css$/o,'')
        if refer_only
          stylesheet_link_tag  "file://#{Rails.root.join('public','stylesheets',source+'.css')}", options          
        else
          "<style type='text/css'>#{File.read(css_dir.join(source+'.css'))}</style>"
        end
      }.join("\n").html_safe
    else
      sources.collect { |source|
        stylesheet_link_tag(source, options)
      }.join("\n").html_safe
    end
  end

  def wicked_pdf_image_tag(img, options={})
    if request.try(:format).to_s == 'application/pdf'
      image_tag "file://#{Rails.root.join('public', 'images', img)}", options rescue nil
    else
      image_tag img.to_s, options rescue nil
    end
  end

  def wicked_pdf_javascript_src_tag(jsfile, options={})
    if request.try(:format).to_s == 'application/pdf'
      jsfile.sub!(/\.js$/o,'')
      javascript_src_tag "file://#{Rails.root.join('public','javascripts',jsfile + '.js')}", options
    else
      javascript_src_tag jsfile, options
    end
  end

  def wicked_pdf_javascript_include_tag(*sources)
    sources.collect{ |source| wicked_pdf_javascript_src_tag(source, {}) }.join("\n").html_safe
  end

  module Assets
    def wicked_pdf_stylesheet_link_tag(*sources)
      sources.collect { |source|
        "<style type='text/css'>#{read_asset(source+".css")}</style>"
      }.join("\n").html_safe
    end

    def wicked_pdf_image_tag(img, options={})
      if request.try(:format).to_s == 'application/pdf'
        image_tag "file://#{asset_pathname(img).to_s}", options
      else
        image_tag img, options
      end
    end

    def wicked_pdf_javascript_src_tag(jsfile, options={})
      if request.try(:format).to_s == 'application/pdf'
        javascript_include_tag "file://#{asset_pathname(jsfile).to_s}", options
      else
        javascript_include_tag jsfile, options
      end
    end

    def wicked_pdf_javascript_include_tag(*sources)
      sources.collect { |source|
        "<script type='text/javascript'>#{read_asset(source+".js")}</script>"
      }.join("\n").html_safe
    end

    private

    def asset_pathname(source)
      if Rails.configuration.assets.compile == false
        File.join(Rails.public_path, asset_path(source))
      else
        # raise Rails.application.assets.find_asset(source).logical_path.inspect
        Rails.application.assets.find_asset(source).pathname
      end
    end

    def read_asset(source)
      if Rails.configuration.assets.compile == false
        IO.read(asset_pathname(source))
      else
        Rails.application.assets.find_asset(source).to_s
      end
    end
  end
end
