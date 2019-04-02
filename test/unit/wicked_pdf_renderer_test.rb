require 'test_helper'

class WickedPdfRendererTest < ActiveSupport::TestCase
  def setup
    @controller = stub(
      'Controller',
      :send_data => 'SEND',
      :render_to_string => 'contents',
      :controller_path => 'foo',
      :action_name => 'create'
    )

    WickedPdf.expects(:new).returns(mock(:pdf_from_string => ''))

    @renderer = WickedPdf::Renderer.new(@controller)
  end

  test 'should prerender header and footer :template options' do
    @controller.expects(:render_to_string).with(has_entry(:template => 'header.html.erb'))
    @controller.expects(:render_to_string).with(has_entry(:template => 'footer.html.erb'))

    @renderer.render(
      :pdf => 'template',
      :header => { :html => { :template => 'header.html.erb' } },
      :footer => { :html => { :template => 'footer.html.erb' } }
    )
  end

  test 'should prerender cleanup temfiles' do
    header_temp = mock('Header tempfile', :path => 'header', :close! => nil, :write => nil, :flush => nil)
    footer_temp = mock('Footer tempfile', :path => 'footer', :close! => nil, :write => nil, :flush => nil)

    WickedPdf::WickedPdfTempfile.expects(:new).with('wicked_header_pdf.html').returns(header_temp)
    WickedPdf::WickedPdfTempfile.expects(:new).with('wicked_footer_pdf.html').returns(footer_temp)

    @renderer.render(
      :pdf => 'template',
      :header => { :html => { :template => 'header.html.erb' } },
      :footer => { :html => { :template => 'footer.html.erb' } }
    )
  end
end
