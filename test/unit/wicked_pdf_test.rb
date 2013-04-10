require 'test_helper'

WickedPdf.config = { :exe_path => ENV['WKHTMLTOPDF_BIN'] || '/usr/local/bin/wkhtmltopdf' }
HTML_DOCUMENT = "<html><body>Hello World</body></html>"

# Provide a public accessor to the normally-private parse_options function
class WickedPdf
  def get_parsed_options(opts)
    parse_options(opts)
  end
end

class WickedPdfTest < ActiveSupport::TestCase
  def setup
    @wp = WickedPdf.new
  end

  test "should generate PDF from html document" do
    wp = WickedPdf.new
    pdf = wp.pdf_from_string HTML_DOCUMENT
    assert pdf.start_with?("%PDF-1.4")
    assert pdf.rstrip.end_with?("%%EOF")
    assert pdf.length > 100
  end
  
  test "should generate PDF from html document with long lines" do
    wp = WickedPdf.new
    document_with_long_line_file = File.new("test/fixtures/document_with_long_line.html", "r")
    pdf = wp.pdf_from_string(document_with_long_line_file.read)
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
        assert_equal  "--#{hf.to_s}-#{o.to_s.gsub('_', '-')} \"header_footer\"",
                      wp.get_parsed_options(hf => {o => "header_footer"}).strip
      end

      [:font_size, :spacing].each do |o|
        assert_equal  "--#{hf.to_s}-#{o.to_s.gsub('_', '-')} 12",
                      wp.get_parsed_options(hf => {o => "12"}).strip
      end

      assert_equal  "--#{hf.to_s}-line",
                    wp.get_parsed_options(hf => {:line => true}).strip
      assert_equal  "--#{hf.to_s}-html \"http://www.abc.com\"",
                    wp.get_parsed_options(hf => {:html => {:url => 'http://www.abc.com'}}).strip
    end
  end

  test "should parse toc options" do
    wp = WickedPdf.new

    [:font_name, :header_text].each do |o|
      assert_equal  "--toc --toc-#{o.to_s.gsub('_', '-')} \"toc\"",
                    wp.get_parsed_options(:toc => {o => "toc"}).strip
    end

    [ :depth, :header_fs, :l1_font_size, :l2_font_size, :l3_font_size, :l4_font_size,
      :l5_font_size, :l6_font_size, :l7_font_size, :l1_indentation, :l2_indentation,
      :l3_indentation, :l4_indentation, :l5_indentation, :l6_indentation, :l7_indentation
    ].each do |o|
      assert_equal  "--toc --toc-#{o.to_s.gsub('_', '-')} 5",
                    wp.get_parsed_options(:toc => {o => 5}).strip
    end

    [:no_dots, :disable_links, :disable_back_links].each do |o|
      assert_equal  "--toc --toc-#{o.to_s.gsub('_', '-')}",
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
      assert_equal "--#{o.to_s.gsub('_', '-')} \"opts\"", wp.get_parsed_options(o => "opts").strip
    end

    [:cookie, :post].each do |o|
      assert_equal "--#{o.to_s.gsub('_', '-')} name value", wp.get_parsed_options(o => "name value").strip

      nv_formatter = Proc.new{|number| "--#{o.to_s.gsub('_', '-')} par#{number} val#{number}" }
      assert_equal "#{nv_formatter.call(1)} #{nv_formatter.call(2)}", wp.get_parsed_options(o => ['par1 val1', 'par2 val2']).strip
    end

    [:redirect_delay, :zoom, :page_offset].each do |o|
      assert_equal "--#{o.to_s.gsub('_', '-')} 5", wp.get_parsed_options(o => 5).strip
    end

    [ :book, :default_header, :disable_javascript, :grayscale, :lowquality,
      :enable_plugins, :disable_internal_links, :disable_external_links,
      :print_media_type, :disable_smart_shrinking, :use_xserver, :no_background
    ].each do |o|
      assert_equal "--#{o.to_s.gsub('_', '-')}", wp.get_parsed_options(o => true).strip
    end
  end

  test "should extract old wkhtmltopdf version" do
    version_info_sample = "Name:\n  wkhtmltopdf 0.9.9\n\nLicense:\n  Copyright (C) 2008,2009 Wkhtmltopdf Authors.\n\n\n\n  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n  This is free software: you are free to change and redistribute it. There is NO\n  WARRANTY, to the extent permitted by law.\n\nAuthors:\n  Written by Jakob Truelsen. Patches by Mrio Silva, Benoit Garret and Emmanuel\n  Bouthenot.\n"
    assert_equal WickedPdf::DEFAULT_BINARY_VERSION, @wp.send(:parse_version, version_info_sample)
  end

  test "should extract new wkhtmltopdf version" do
    version_info_sample = "Name:\n  wkhtmltopdf 0.11.0 rc2\n\nLicense:\n  Copyright (C) 2010 wkhtmltopdf/wkhtmltoimage Authors.\n\n\n\n  License LGPLv3+: GNU Lesser General Public License version 3 or later\n  <http://gnu.org/licenses/lgpl.html>. This is free software: you are free to\n  change and redistribute it. There is NO WARRANTY, to the extent permitted by\n  law.\n\nAuthors:\n  Written by Jan Habermann, Christian Sciberras and Jakob Truelsen. Patches by\n  Mehdi Abbad, Lyes Amazouz, Pascal Bach, Emmanuel Bouthenot, Benoit Garret and\n  Mario Silva."
    assert_equal Gem::Version.new('0.11.0'), @wp.send(:parse_version, version_info_sample)
  end

  test "should extract wkhtmltopdf version with nondigit symbols" do
    version_info_sample = "Name:\n  wkhtmltopdf 0.10.4b\n\nLicense:\n  Copyright (C) 2008,2009 Wkhtmltopdf Authors.\n\n\n\n  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n  This is free software: you are free to change and redistribute it. There is NO\n  WARRANTY, to the extent permitted by law.\n\nAuthors:\n  Written by Jakob Truelsen. Patches by Mrio Silva, Benoit Garret and Emmanuel\n  Bouthenot.\n"
    assert_equal Gem::Version.new('0.10.4b'), @wp.send(:parse_version, version_info_sample)
  end

  test "should fallback to default version on parse error" do
    assert_equal WickedPdf::DEFAULT_BINARY_VERSION, @wp.send(:parse_version, '')
  end

  test "should set Default version on initialize" do
    assert_equal WickedPdf::DEFAULT_BINARY_VERSION, @wp.send(:get_binary_version)
  end
end
