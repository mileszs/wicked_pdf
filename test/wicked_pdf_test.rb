require 'test_helper'

WickedPdf.config = { :exe_path => '/usr/local/bin/wkhtmltopdf' }
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
    begin
      tmp = Tempfile.new('wkhtmltopdf')
      fp = tmp.path
      File.chmod 0000, fp
      assert_raise RuntimeError do
        WickedPdf.new fp
      end
    ensure
      tmp.delete
    end
  end

  test "should raise exception when pdf generation fails" do
    begin
      tmp = Tempfile.new('wkhtmltopdf')
      fp = tmp.path
      File.chmod 0777, fp
      wp = WickedPdf.new fp
      assert_raise RuntimeError do
        wp.pdf_from_string HTML_DOCUMENT
      end
    ensure
      tmp.delete
    end
  end

  test "should parse header and footer options" do
    wp = WickedPdf.new

    [:header, :footer].each do |hf|
      [:center, :font_name, :left, :right].each do |o|
        assert_equal  "--#{hf.to_s}-#{o.to_s.gsub('_', '-')} 'header_footer'",
                      wp.get_parsed_options(hf => {o => "header_footer"}).strip
      end

      [:font_size, :spacing].each do |o|
        assert_equal  "--#{hf.to_s}-#{o.to_s.gsub('_', '-')} 12",
                      wp.get_parsed_options(hf => {o => "12"}).strip
      end

      assert_equal  "--#{hf.to_s}-line",
                    wp.get_parsed_options(hf => {:line => true}).strip
      assert_equal  "--#{hf.to_s}-html 'http://www.abc.com'",
                    wp.get_parsed_options(hf => {:html => {:url => 'http://www.abc.com'}}).strip
    end
  end

  test "should parse toc options" do
    wp = WickedPdf.new

    [:font_name, :header_text].each do |o|
      assert_equal  "--toc-#{o.to_s.gsub('_', '-')} 'toc'",
                    wp.get_parsed_options(:toc => {o => "toc"}).strip
    end

    [ :depth, :header_fs, :l1_font_size, :l2_font_size, :l3_font_size, :l4_font_size,
      :l5_font_size, :l6_font_size, :l7_font_size, :l1_indentation, :l2_indentation,
      :l3_indentation, :l4_indentation, :l5_indentation, :l6_indentation, :l7_indentation
    ].each do |o|
      assert_equal  "--toc-#{o.to_s.gsub('_', '-')} 5",
                    wp.get_parsed_options(:toc => {o => 5}).strip
    end

    [:no_dots, :disable_links, :disable_back_links].each do |o|
      assert_equal  "--toc-#{o.to_s.gsub('_', '-')}",
                    wp.get_parsed_options(:toc => {o => true}).strip
    end
  end

  test "should parse outline options" do
    wp = WickedPdf.new

    assert_equal "--outline", wp.get_parsed_options(:outline => {:outline => true}).strip
    assert_equal "--outline-depth 5", wp.get_parsed_options(:outline => {:outline_depth => 5}).strip
  end

  test "should parse margins options" do
    wp = WickedPdf.new

    [:top, :bottom, :left, :right].each do |o|
      assert_equal "--margin-#{o.to_s} 12", wp.get_parsed_options(:margin => {o => "12"}).strip
    end
  end

  test "should parse other options" do
    wp = WickedPdf.new

    [ :orientation, :page_size, :proxy, :username, :password, :cover, :dpi,
      :encoding, :user_style_sheet
    ].each do |o|
      assert_equal "--#{o.to_s.gsub('_', '-')} 'opts'", wp.get_parsed_options(o => "opts").strip
    end

    [:redirect_delay, :zoom, :page_offset].each do |o|
      assert_equal "--#{o.to_s.gsub('_', '-')} 5", wp.get_parsed_options(o => 5).strip
    end

    [ :book, :default_header, :disable_javascript, :greyscale, :lowquality,
      :enable_plugins, :disable_internal_links, :disable_external_links,
      :print_media_type, :disable_smart_shrinking, :use_xserver, :no_background
    ].each do |o|
      assert_equal "--#{o.to_s.gsub('_', '-')}", wp.get_parsed_options(o => true).strip
    end
  end
end
