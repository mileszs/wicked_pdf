require 'test_helper'

WICKED_PDF = { :exe_path => '/usr/local/bin/wkhtmltopdf' }
HTML_DOCUMENT = "<html><body>Hello World</body></html>"

class WickedPdfTest < ActiveSupport::TestCase
  test "should generate PDF from html document" do
    wp = WickedPdf.new
    pdf = wp.pdf_from_string HTML_DOCUMENT
    assert pdf.start_with?("%PDF-1.4")
    assert pdf.rstrip.end_with?("%%EOF")
    assert pdf.length > 100
  end

  test "should raise exception when no path to wkhtmltopdf" do
    assert_raise RuntimeError do
      WickedPdf.new " "
    end
  end

  test "should raise exception when wkhtmltopdf path is wrong" do
    assert_raise RuntimeError do
      WickedPdf.new "/i/do/not/exist/notwkhtmltopdf"
    end
  end

  test "should raise exception when wkhtmltopdf is not executable" do
    fp = File.expand_path(File.dirname(__FILE__)) + '/wkhtmltopdf'
    File.chmod 0000, fp
    assert_raise RuntimeError do
      WickedPdf.new fp 
    end
    File.chmod 0755, fp
  end

  test "should raise exception when pdf generation fails" do
    fp = File.expand_path(File.dirname(__FILE__)) + '/wkhtmltopdf'
    File.chmod 0777, fp
    wp = WickedPdf.new fp
    assert_raise RuntimeError do
      wp.pdf_from_string HTML_DOCUMENT 
    end
  end
end
