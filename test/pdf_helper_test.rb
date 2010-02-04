require 'test_helper'

module ActionController
  class Base
    def render_to_string opts={}
      opts.to_s
    end
  end
end

class PdfHelperTest < ActionController::TestCase
  def setup
    @ac = ActionController::Base.new
  end

  def teardown
    @ac=nil
  end

  test "should parse header and footer options" do
    [:header, :footer].collect do |hf|
      [:center, :font_name, :left, :right].collect {|o| assert_equal @ac.parse_options(hf => {o => "header_footer"}).strip, "--#{hf.to_s}-#{o.to_s.gsub('_', '-')} 'header_footer'"}
      [:font_size, :spacing].collect {|o| assert_equal @ac.parse_options(hf => {o => "12"}).strip, "--#{hf.to_s}-#{o.to_s.gsub('_', '-')} 12"}
      assert_equal @ac.parse_options(hf => {:line => true}).strip, "--#{hf.to_s}-line"
      assert_equal @ac.parse_options(hf => {:html => {:url => 'http://www.abc.com'}}).strip, "--#{hf.to_s}-html 'http://www.abc.com'"

      assert_match /^--(header|footer)-html 'file:\/\/.*wicked_pdf.*\.html'/, @ac.parse_options(:layout => "pdf.html.erb", hf => {:html => {:template => 'hf.html.erb'}}).strip 
    end
  end

  test "should parse toc options" do
    [:font_name, :header_text].collect {|o| assert_equal @ac.parse_options(:toc => {o => "toc"}).strip, "--toc-#{o.to_s.gsub('_', '-')} 'toc'"}
    [:depth, :header_fs, :l1_font_size, :l2_font_size, :l3_font_size, :l4_font_size, :l5_font_size, :l6_font_size, :l7_font_size, :l1_indentation, :l2_indentation, :l3_indentation, :l4_indentation, :l5_indentation, :l6_indentation, :l7_indentation].collect {|o| assert_equal @ac.parse_options(:toc => {o => 5}).strip, "--toc-#{o.to_s.gsub('_', '-')} 5"}
    [:no_dots, :disable_links, :disable_back_links].collect {|o| assert_equal @ac.parse_options(:toc => {o => true}).strip, "--toc-#{o.to_s.gsub('_', '-')}"}
  end

  test "should parse outline options" do
    assert_equal @ac.parse_options(:outline => {:outline => true}).strip, "--outline"
    assert_equal @ac.parse_options(:outline => {:outline_depth => 5}).strip, "--outline-depth 5"
  end

  test "should parse margins options" do
    [:top, :bottom, :left, :right].collect {|o| assert_equal @ac.parse_options(:margin => {o => "12"}).strip, "--margin-#{o.to_s} 12"}
  end

  test "should parse other options" do
    [:orientation, :page_size, :proxy, :username, :password, :cover, :dpi, :encoding, :user_style_sheet].collect {|o| assert_equal @ac.parse_options(o => "opts").strip, "--#{o.to_s.gsub('_', '-')} 'opts'"}
    [:redirect_delay, :zoom, :page_offset].collect {|o| assert_equal @ac.parse_options(o => 5).strip, "--#{o.to_s.gsub('_', '-')} 5"}
    [:book, :default_header, :disable_javascript, :greyscale, :lowquality, :enable_plugins, :disable_internal_links, :disable_external_links, :print_media_type, :disable_smart_shrinking, :use_xserver, :no_background].collect {|o| assert_equal @ac.parse_options(o => true).strip, "--#{o.to_s.gsub('_', '-')}"}
  end
end
