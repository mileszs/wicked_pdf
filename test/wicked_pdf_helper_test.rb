require 'test_helper'

class WickedPdfHelperTest < ActionView::TestCase
  test 'wicked_pdf_stylesheet_link_tag should inline the stylesheets passed in' do
    assert_equal "<style type='text/css'>/* Wicked styles */\n</style>",
                 wicked_pdf_stylesheet_link_tag('../../vendor/plugins/wicked_pdf/test/fixtures/wicked')
  end

  test 'wicked_pdf_image_tag should return the same as image_tag when passed a full path' do
    assert_equal image_tag("file://#{Rails.root.join('public','images','pdf')}"),
                 wicked_pdf_image_tag('pdf')
  end

  test 'wicked_pdf_javascript_src_tag should return the same as javascript_src_tag when passed a full path' do
    assert_equal javascript_src_tag("file://#{Rails.root.join('public','javascripts','pdf')}", {}),
                 wicked_pdf_javascript_src_tag('pdf')
  end

  test 'wicked_pdf_include_tag should return many wicked_pdf_javascript_src_tags' do
    assert_equal [wicked_pdf_javascript_src_tag('foo'), wicked_pdf_javascript_src_tag('bar')].join("\n"),
                 wicked_pdf_javascript_include_tag('foo', 'bar')
  end
end
