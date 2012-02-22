require 'test_helper'
require 'action_view/test_case'

class FakeRequest
  attr_accessor :format
  def initialize(format = 'application/pdf')
    @format = format
  end
end

class WickedPdfHelperTest < ActionView::TestCase
  def request
    @fake_request
  end
  
  def setup
    @fake_request = FakeRequest.new
  end
  
  test "the fake request works properly" do
    assert_equal('application/pdf', request.format.to_s)
    @fake_request = FakeRequest.new('text/html')
    assert_equal('text/html', request.format.to_s)
  end
  
  test 'wicked_pdf_stylesheet_link_tag should inline the stylesheets passed in' do
    assert_equal "<style type='text/css'>/* Wicked styles */\n</style>",
                 wicked_pdf_stylesheet_link_tag('../../vendor/plugins/wicked_pdf/test/fixtures/wicked')
    # with .css extension
    assert_equal "<style type='text/css'>/* Wicked styles */\n</style>",
                wicked_pdf_stylesheet_link_tag('../../vendor/plugins/wicked_pdf/test/fixtures/wicked.css')

    @fake_request = FakeRequest.new('text/html')
    assert_equal stylesheet_link_tag('../../vendor/plugins/wicked_pdf/test/fixtures/wicked.css'), 
                wicked_pdf_stylesheet_link_tag('../../vendor/plugins/wicked_pdf/test/fixtures/wicked.css')
  end
  
  test "wicked_pdf_stylesheet_link_tag should only refer the stylesheets passed in" do
    assert_equal stylesheet_link_tag("file://#{Rails.root.join('public','stylesheets','foo.css')}", "file://#{Rails.root.join('public','stylesheets','bar.css')}"),
                 wicked_pdf_stylesheet_link_tag('foo', 'bar', :refer_only => true)
  end

  test 'wicked_pdf_image_tag should return the same as image_tag when passed a full path' do
    assert_equal image_tag("file://#{Rails.root.join('public','images','pdf')}"),
                 wicked_pdf_image_tag('pdf')
                 
    @fake_request = FakeRequest.new('text/html')
    assert_equal image_tag('pdf'), 
                 wicked_pdf_image_tag('pdf')
  end

  test 'wicked_pdf_javascript_src_tag should return the same as javascript_src_tag when passed a full path' do
    assert_equal javascript_src_tag("file://#{Rails.root.join('public','javascripts','pdf.js')}", {}),
                 wicked_pdf_javascript_src_tag('pdf')
    # with .js extension
    assert_equal javascript_src_tag("file://#{Rails.root.join('public','javascripts','pdf.js')}", {}),
                wicked_pdf_javascript_src_tag('pdf.js')

    @fake_request = FakeRequest.new('text/html')
    assert_equal javascript_src_tag('pdf', {}), 
                 wicked_pdf_javascript_src_tag('pdf')
  end

  test 'wicked_pdf_include_tag should return many wicked_pdf_javascript_src_tags' do
    assert_equal [wicked_pdf_javascript_src_tag('foo'), wicked_pdf_javascript_src_tag('bar')].join("\n"),
                 wicked_pdf_javascript_include_tag('foo', 'bar')
    # with .js extension
    assert_equal [wicked_pdf_javascript_src_tag('foo'), wicked_pdf_javascript_src_tag('bar.js')].join("\n"),
                 wicked_pdf_javascript_include_tag('foo.js', 'bar')

    @fake_request = FakeRequest.new('text/html')
    assert_equal [wicked_pdf_javascript_src_tag('foo'), wicked_pdf_javascript_src_tag('bar')].join("\n"),
                 wicked_pdf_javascript_include_tag('foo', 'bar')
  end
end
