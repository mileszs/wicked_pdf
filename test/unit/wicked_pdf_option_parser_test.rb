require 'test_helper'

class WickedPdfOptionParserTest < ActiveSupport::TestCase
  test 'should parse header and footer options' do
    %i[header footer].each do |hf|
      %i[center font_name left right].each do |o|
        assert_equal "--#{hf}-#{o.to_s.tr('_', '-')} header_footer",
                     parse_options(hf => { o => 'header_footer' }).strip
      end

      %i[font_size spacing].each do |o|
        assert_equal "--#{hf}-#{o.to_s.tr('_', '-')} 12",
                     parse_options(hf => { o => '12' }).strip
      end

      assert_equal "--#{hf}-line",
                   parse_options(hf => { :line => true }).strip
      assert_equal "--#{hf}-html http://www.abc.com",
                   parse_options(hf => { :html => { :url => 'http://www.abc.com' } }).strip
    end
  end

  test 'should parse toc options' do
    toc_option = option_parser.valid_option('toc')

    %i[font_name header_text].each do |o|
      assert_equal "#{toc_option} --toc-#{o.to_s.tr('_', '-')} toc",
                   parse_options(:toc => { o => 'toc' }).strip
    end

    %i[
      depth header_fs l1_font_size l2_font_size l3_font_size l4_font_size
      l5_font_size l6_font_size l7_font_size l1_indentation l2_indentation
      l3_indentation l4_indentation l5_indentation l6_indentation l7_indentation
    ].each do |o|
      assert_equal "#{toc_option} --toc-#{o.to_s.tr('_', '-')} 5",
                   parse_options(:toc => { o => 5 }).strip
    end

    %i[no_dots disable_links disable_back_links].each do |o|
      assert_equal "#{toc_option} --toc-#{o.to_s.tr('_', '-')}",
                   parse_options(:toc => { o => true }).strip
    end
  end

  test 'should parse outline options' do
    assert_equal '--outline', parse_options(:outline => { :outline => true }).strip
    assert_equal '--outline-depth 5', parse_options(:outline => { :outline_depth => 5 }).strip
  end

  test 'should parse no_images option' do
    assert_equal '--no-images', parse_options(:no_images => true).strip
    assert_equal '--images', parse_options(:images => true).strip
  end

  test 'should parse margins options' do
    %i[top bottom left right].each do |o|
      assert_equal "--margin-#{o} 12", parse_options(:margin => { o => '12' }).strip
    end
  end

  test 'should parse cover' do
    cover_option = option_parser.valid_option('cover')

    pathname = Rails.root.join('app', 'views', 'pdf', 'file.html')
    assert_equal "#{cover_option} http://example.org", parse_options(:cover => 'http://example.org').strip, 'URL'
    assert_equal "#{cover_option} #{pathname}", parse_options(:cover => pathname).strip, 'Pathname'
    assert_match(/#{cover_option} .+wicked_cover_pdf.+\.html/, parse_options(:cover => '<html><body>HELLO</body></html>').strip, 'HTML')
  end

  test 'should parse other options' do
    %i[
      orientation page_size proxy username password dpi
      encoding user_style_sheet
    ].each do |o|
      assert_equal "--#{o.to_s.tr('_', '-')} opts", parse_options(o => 'opts').strip
    end

    %i[cookie post].each do |o|
      assert_equal "--#{o.to_s.tr('_', '-')} name value", parse_options(o => 'name value').strip

      nv_formatter = proc { |number| "--#{o.to_s.tr('_', '-')} par#{number} val#{number}" }
      assert_equal "#{nv_formatter.call(1)} #{nv_formatter.call(2)}", parse_options(o => ['par1 val1', 'par2 val2']).strip
    end

    %i[redirect_delay zoom page_offset].each do |o|
      assert_equal "--#{o.to_s.tr('_', '-')} 5", parse_options(o => 5).strip
    end

    %i[
      book default_header disable_javascript grayscale lowquality
      enable_plugins disable_internal_links disable_external_links
      print_media_type disable_smart_shrinking use_xserver no_background
    ].each do |o|
      assert_equal "--#{o.to_s.tr('_', '-')}", parse_options(o => true).strip
    end
  end

  test 'should not use double dash options for version without dashes' do
    op = option_parser(WickedPdf::OptionParser::BINARY_VERSION_WITHOUT_DASHES)

    %w[toc cover].each do |name|
      assert_equal op.valid_option(name), name
    end
  end

  test 'should use double dash options for version with dashes' do
    op = option_parser(Gem::Version.new('0.11.0'))

    %w[toc cover].each do |name|
      assert_equal op.valid_option(name), "--#{name}"
    end
  end

  test '-- options should not be given after object' do
    options = { :header => { :center => 3 }, :cover => 'http://example.org', :disable_javascript => true }
    cover_option = option_parser.valid_option('cover')
    assert_equal parse_options(options), "--disable-javascript --header-center 3 #{cover_option} http://example.org"
  end

  def parse_options(options, version = WickedPdf::DEFAULT_BINARY_VERSION)
    option_parser(version).parse(options).join(' ')
  end

  def option_parser(version = WickedPdf::DEFAULT_BINARY_VERSION)
    WickedPdf::OptionParser.new(version)
  end
end
