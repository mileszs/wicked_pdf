module WickedPdfHelper
  def wicked_pdf_stylesheet_link_tag(style)
    stylesheet_link_tag style, Rails.root('public','stylesheets',style).to_s
  end

  def wicked_pdf_image_tag(img, options={})
    image_tag Rails.root.join('public','images',img).to_s, options
  end
end
