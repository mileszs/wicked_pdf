require 'test_helper'

class WickedPdfHelperTest < ActionView::TestCase
  test 'should return the same as stylesheet_link_tag when passed a full path' do
    assert_equal wicked_pdf_stylesheet_link_tag('pdf'),
                 stylesheet_link_tag('pdf', Rails.root.join('public','stylesheets','pdf').to_s)
  end

  test 'should return the same as image_tag when passed a full path' do
    assert_equal wicked_pdf_image_tag('pdf'),
                 image_tag(Rails.root.join('public','images','pdf').to_s)
  end

  test 'should return the same as javascript_src_tag when passed a full path' do
    assert_equal wicked_pdf_javascript_src_tag('pdf'),
                 javascript_src_tag(Rails.root.join('public','javascripts','pdf').to_s, {})
  end

  test 'should return many wicked_pdf_javascript_src_tags on wicked_pdf_javascript_include_tag' do
    assert_equal wicked_pdf_javascript_include_tag('foo', 'bar'),
                 [wicked_pdf_javascript_src_tag('foo'), wicked_pdf_javascript_src_tag('bar')].join("\n")
  end
end
