require 'test_helper'

WICKED_PDF = { :exe_path => '/usr/local/bin/wkhtmltopdf' }
HTML_DOCUMENT = "<html><body>Hello World</body></html>"

# Provide a public accessor to the normally-private parse_options function
class WickedPdf
  def get_parsed_options(opts)
    parse_options(opts)
  end
end

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

  test "should parse header and footer options" do
    wp = WickedPdf.new

    [:header, :footer].collect do |hf|
      [:center, :font_name, :left, :right].collect {|o| assert_equal wp.get_parsed_options(hf => {o => "header_footer"}).strip, "--#{hf.to_s}-#{o.to_s.gsub('_', '-')} 'header_footer'"}
      [:font_size, :spacing].collect {|o| assert_equal wp.get_parsed_options(hf => {o => "12"}).strip, "--#{hf.to_s}-#{o.to_s.gsub('_', '-')} 12"}
      assert_equal wp.get_parsed_options(hf => {:line => true}).strip, "--#{hf.to_s}-line"
      assert_equal wp.get_parsed_options(hf => {:html => {:url => 'http://www.abc.com'}}).strip, "--#{hf.to_s}-html 'http://www.abc.com'"
    end
  end

  test "should parse toc options" do
    wp = WickedPdf.new

    [:font_name, :header_text].collect {|o| assert_equal wp.get_parsed_options(:toc => {o => "toc"}).strip, "--toc-#{o.to_s.gsub('_', '-')} 'toc'"}
    [:depth, :header_fs, :l1_font_size, :l2_font_size, :l3_font_size, :l4_font_size, :l5_font_size, :l6_font_size, :l7_font_size, :l1_indentation, :l2_indentation, :l3_indentation, :l4_indentation, :l5_indentation, :l6_indentation, :l7_indentation].collect {|o| assert_equal wp.get_parsed_options(:toc => {o => 5}).strip, "--toc-#{o.to_s.gsub('_', '-')} 5"}
    [:no_dots, :disable_links, :disable_back_links].collect {|o| assert_equal wp.get_parsed_options(:toc => {o => true}).strip, "--toc-#{o.to_s.gsub('_', '-')}"}
  end

  test "should parse outline options" do
    wp = WickedPdf.new

    assert_equal wp.get_parsed_options(:outline => {:outline => true}).strip, "--outline"
    assert_equal wp.get_parsed_options(:outline => {:outline_depth => 5}).strip, "--outline-depth 5"
  end

  test "should parse margins options" do
    wp = WickedPdf.new

    [:top, :bottom, :left, :right].collect {|o| assert_equal wp.get_parsed_options(:margin => {o => "12"}).strip, "--margin-#{o.to_s} 12"}
  end

  test "should parse other options" do
    wp = WickedPdf.new

    [:orientation, :page_size, :proxy, :username, :password, :cover, :dpi, :encoding, :user_style_sheet].collect {|o| assert_equal wp.get_parsed_options(o => "opts").strip, "--#{o.to_s.gsub('_', '-')} 'opts'"}
    [:redirect_delay, :zoom, :page_offset].collect {|o| assert_equal wp.get_parsed_options(o => 5).strip, "--#{o.to_s.gsub('_', '-')} 5"}
    [:book, :default_header, :disable_javascript, :greyscale, :lowquality, :enable_plugins, :disable_internal_links, :disable_external_links, :print_media_type, :disable_smart_shrinking, :use_xserver, :no_background].collect {|o| assert_equal wp.get_parsed_options(o => true).strip, "--#{o.to_s.gsub('_', '-')}"}
  end
end
