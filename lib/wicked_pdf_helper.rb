module WickedPdfHelper
  def wicked_pdf_stylesheet_link_tag style
    stylesheet_link_tag style, "#{RAILS_ROOT}/public/stylesheets/#{style}"
  end
end
