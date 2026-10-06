require 'test_helper'
WickedPdf.config = { :exe_path => ENV['WKHTMLTOPDF_BIN'] || '/usr/local/bin/wkhtmltopdf' }
HTML_DOCUMENT = '<html><body>Hello World</body></html>'.freeze

class WickedPdfTest < ActiveSupport::TestCase
  def setup
    @wp = WickedPdf.new
  end

  test 'should update config through .configure class method' do
    WickedPdf.configure do |c|
      c.test = 'foobar'
    end

    assert WickedPdf.config == { :exe_path => ENV['WKHTMLTOPDF_BIN'] || '/usr/local/bin/wkhtmltopdf', :test => 'foobar' }
  end

  test 'should merge .configure options into the existing config' do
    backup_config = WickedPdf.config.dup
    WickedPdf.config = { :exe_path => '/old/wkhtmltopdf', :layout => 'old.html' }

    WickedPdf.configure do |c|
      c.layout = 'pdf.html'
      c.use_xvfb = true
    end

    assert_equal({ :exe_path => '/old/wkhtmltopdf', :layout => 'pdf.html', :use_xvfb => true }, WickedPdf.config)
  ensure
    WickedPdf.config = backup_config
  end

  test 'should read options back inside a .configure block' do
    backup_config = WickedPdf.config.dup
    WickedPdf.config = { :exe_path => '/old/wkhtmltopdf' }

    WickedPdf.configure do |c|
      assert_equal '/old/wkhtmltopdf', c.exe_path
      c.layout = 'pdf.html'
      assert_equal 'pdf.html', c.layout
      assert_nil c.never_set_option
      assert_respond_to c, :layout
      assert_respond_to c, :any_option=
      refute_respond_to c, :never_set_option
    end
  ensure
    WickedPdf.config = backup_config
  end

  test 'should clear config through .clear_config class method' do
    backup_config = WickedPdf.config

    WickedPdf.clear_config
    assert WickedPdf.config == {}

    WickedPdf.config = backup_config
  end

  test 'should generate PDF from html document' do
    pdf = @wp.pdf_from_string HTML_DOCUMENT
    assert pdf.start_with?('%PDF-1.4')
    assert pdf.rstrip.end_with?('%%EOF')
    assert pdf.length > 100
  end

  test 'should generate PDF from html document with long lines' do
    document_with_long_line_file = File.new('test/fixtures/document_with_long_line.html', 'r')
    pdf = @wp.pdf_from_string(document_with_long_line_file.read)
    assert pdf.start_with?('%PDF-1.4')
    assert pdf.rstrip.end_with?('%%EOF')
    assert pdf.length > 100
  end

  test 'should generate PDF from html existing HTML file without converting it to string' do
    filepath = File.join(Dir.pwd, 'test/fixtures/document_with_long_line.html')
    pdf = @wp.pdf_from_html_file(filepath)
    assert pdf.start_with?('%PDF-1.4')
    assert pdf.rstrip.end_with?('%%EOF')
    assert pdf.length > 100
  end

  test 'should raise exception when no path to wkhtmltopdf' do
    assert_raise RuntimeError do
      WickedPdf.new ' '
    end
  end

  test 'should raise exception when wkhtmltopdf path is wrong' do
    assert_raise RuntimeError do
      WickedPdf.new '/i/do/not/exist/notwkhtmltopdf'
    end
  end

  test 'should raise exception when wkhtmltopdf is not executable' do
    begin
      tmp = Tempfile.new('wkhtmltopdf')
      fp = tmp.path
      File.chmod 0o000, fp
      assert_raise RuntimeError do
        WickedPdf.new fp
      end
    ensure
      tmp.delete
    end
  end

  test 'should raise exception when pdf generation fails' do
    begin
      tmp = Tempfile.new('wkhtmltopdf')
      fp = tmp.path
      File.chmod 0o777, fp
      wp = WickedPdf.new fp
      assert_raise RuntimeError do
        wp.pdf_from_string HTML_DOCUMENT
      end
    ensure
      tmp.delete
    end
  end

  test 'should output progress when creating pdfs on compatible hosts' do
    wp = WickedPdf.new
    output = []
    options = { :progress => proc { |o| output << o } }
    wp.pdf_from_string HTML_DOCUMENT, options
    if RbConfig::CONFIG['target_os'] =~ /mswin|mingw/
      assert_empty output
    else
      assert(output.collect { |l| !l.match(/Loading/).nil? }.include?(true)) # should output something like "Loading pages (1/5)"
    end
  end
end
