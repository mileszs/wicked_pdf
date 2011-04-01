module WickedPdfHelper
  def wicked_pdf_stylesheet_link_tag(style, options={})
    stylesheet_link_tag style, "file://#{Rails.root.join('public','stylesheets',style)}", options
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
end
