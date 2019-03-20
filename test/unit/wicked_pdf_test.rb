require 'test_helper'
WickedPdf.config = { :exe_path => ENV['WKHTMLTOPDF_BIN'] || '/usr/local/bin/wkhtmltopdf' }
HTML_DOCUMENT = '<html><body>Hello World</body></html>'.freeze

class WickedPdfTest < ActiveSupport::TestCase
  def setup
    @wp = WickedPdf.new
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

  test 'should extract old wkhtmltopdf version' do
    version_info_sample = "Name:\n  wkhtmltopdf 0.9.9\n\nLicense:\n  Copyright (C) 2008,2009 Wkhtmltopdf Authors.\n\n\n\n  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n  This is free software: you are free to change and redistribute it. There is NO\n  WARRANTY, to the extent permitted by law.\n\nAuthors:\n  Written by Jakob Truelsen. Patches by Mrio Silva, Benoit Garret and Emmanuel\n  Bouthenot.\n"
    assert_equal WickedPdf::DEFAULT_BINARY_VERSION, @wp.send(:parse_version, version_info_sample)
  end

  test 'should extract new wkhtmltopdf version' do
    version_info_sample = "Name:\n  wkhtmltopdf 0.11.0 rc2\n\nLicense:\n  Copyright (C) 2010 wkhtmltopdf/wkhtmltoimage Authors.\n\n\n\n  License LGPLv3+: GNU Lesser General Public License version 3 or later\n  <http://gnu.org/licenses/lgpl.html>. This is free software: you are free to\n  change and redistribute it. There is NO WARRANTY, to the extent permitted by\n  law.\n\nAuthors:\n  Written by Jan Habermann, Christian Sciberras and Jakob Truelsen. Patches by\n  Mehdi Abbad, Lyes Amazouz, Pascal Bach, Emmanuel Bouthenot, Benoit Garret and\n  Mario Silva."
    assert_equal Gem::Version.new('0.11.0'), @wp.send(:parse_version, version_info_sample)
  end

  test 'should extract wkhtmltopdf version with nondigit symbols' do
    version_info_sample = "Name:\n  wkhtmltopdf 0.10.4b\n\nLicense:\n  Copyright (C) 2008,2009 Wkhtmltopdf Authors.\n\n\n\n  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n  This is free software: you are free to change and redistribute it. There is NO\n  WARRANTY, to the extent permitted by law.\n\nAuthors:\n  Written by Jakob Truelsen. Patches by Mrio Silva, Benoit Garret and Emmanuel\n  Bouthenot.\n"
    assert_equal Gem::Version.new('0.10.4b'), @wp.send(:parse_version, version_info_sample)
  end

  test 'should fallback to default version on parse error' do
    assert_equal WickedPdf::DEFAULT_BINARY_VERSION, @wp.send(:parse_version, '')
  end

  test 'should set version on initialize' do
    assert_not_equal @wp.send(:binary_version), ''
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
