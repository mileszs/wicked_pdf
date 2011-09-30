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
    options = sources.extract_options!
    sources.collect{ |source| wicked_pdf_javascript_src_tag(source, options) }.join("\n").html_safe
  end
end
