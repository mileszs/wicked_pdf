require 'test_helper'

class WickedPdfHelperTest < ActionView::TestCase
  test "should return valid html code stylesheet_link_tag helper" do
    assert_equal wicked_pdf_stylesheet_link_tag("pdf"), stylesheet_link_tag("pdf", "#{Rails.root}/public/stylesheets/pdf")
  end
end
