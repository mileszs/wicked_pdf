module WickedPdfHelper
  def wicked_pdf_stylesheet_link_tag(style)
    stylesheet_link_tag style, Rails.root('public','stylesheets',style).to_s
  end

  def wicked_pdf_image_tag(img, options={})
    image_tag Rails.root.join('public','images',img).to_s, options
  end

  def wicked_pdf_javascript_src_tag(jsfile, options={})
    javascript_src_tag Rails.root.join('public','javascripts',jsfile).to_s, options
  end

  def wicked_pdf_javascript_include_tag(*sources)
    sources.collect{ |source| wicked_pdf_javascript_src_tag(source, {}) }.join("\n").html_safe
  end
end
