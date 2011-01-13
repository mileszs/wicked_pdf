require 'test_helper'

class WickedPdfHelperTest < ActionView::TestCase
  test 'should return the same as stylesheet_link_tag when passed a full path' do
    assert_equal wicked_pdf_stylesheet_link_tag('pdf'),
                 stylesheet_link_tag('pdf', Rails.root.join('public','stylesheets','pdf').to_s)
  end
end
