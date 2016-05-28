# wkhtml2pdf Ruby interface
# http://code.google.com/p/wkhtmltopdf/

require 'logger'
require 'digest/md5'
require 'rbconfig'

if (RbConfig::CONFIG['target_os'] =~ /mswin|mingw/) && (RUBY_VERSION < '1.9')
  require 'win32/open3'
else
  require 'open3'
end

begin
  require 'active_support/core_ext/module/attribute_accessors'
rescue LoadError
  require 'active_support/core_ext/class/attribute_accessors'
end

begin
  require 'active_support/core_ext/object/blank'
rescue LoadError
  require 'active_support/core_ext/blank'
end

require 'wicked_pdf/version'
require 'wicked_pdf/railtie'
require 'wicked_pdf/tempfile'
require 'wicked_pdf/middleware'

class WickedPdf
  DEFAULT_BINARY_VERSION = Gem::Version.new('0.9.9')
  BINARY_VERSION_WITHOUT_DASHES = Gem::Version.new('0.12.0')
  EXE_NAME = 'wkhtmltopdf'.freeze
  @@config = {}
  cattr_accessor :config
  attr_accessor :binary_version

  def initialize(wkhtmltopdf_binary_path = nil)
    @exe_path = wkhtmltopdf_binary_path || find_wkhtmltopdf_binary_path
    raise "Location of #{EXE_NAME} unknown" if @exe_path.empty?
    raise "Bad #{EXE_NAME}'s path: #{@exe_path}" unless File.exist?(@exe_path)
    raise "#{EXE_NAME} is not executable" unless File.executable?(@exe_path)

    retrieve_binary_version
  end

  def pdf_from_html_file(filepath, options = {})
    pdf_from_url("file:///#{filepath}", options)
  end

  def pdf_from_string(string, options = {})
    options = options.dup
    options.merge!(WickedPdf.config) { |_key, option, _config| option }
    string_file = WickedPdfTempfile.new('wicked_pdf.html', options[:temp_path])
    string_file.binmode
    string_file.write(string)
    string_file.close

    pdf = pdf_from_html_file(string_file.path, options)
    pdf
  ensure
    string_file.close! if string_file
  end

  def pdf_from_url(url, options = {})
    # merge in global config options
    options.merge!(WickedPdf.config) { |_key, option, _config| option }
    generated_pdf_file = WickedPdfTempfile.new('wicked_pdf_generated_file.pdf', options[:temp_path])
    command = [@exe_path]
    command << '-q' unless on_windows? # suppress errors on stdout
    command += parse_options(options)
    command << url
    command << generated_pdf_file.path.to_s

    print_command(command.inspect) if in_development_mode?

    err = Open3.popen3(*command) do |_stdin, _stdout, stderr|
      stderr.read
    end
    if options[:return_file]
      return_file = options.delete(:return_file)
      return generated_pdf_file
    end
    generated_pdf_file.rewind
    generated_pdf_file.binmode
    pdf = generated_pdf_file.read
    raise "PDF could not be generated!\n Command Error: #{err}" if pdf && pdf.rstrip.empty?
    pdf
  rescue => e
    raise "Failed to execute:\n#{command}\nError: #{e}"
  ensure
    generated_pdf_file.close! if generated_pdf_file && !return_file
  end

  private

  def in_development_mode?
    return Rails.env == 'development' if defined?(Rails)
    RAILS_ENV == 'development' if defined?(RAILS_ENV)
  end

  def on_windows?
    RbConfig::CONFIG['target_os'] =~ /mswin|mingw/
  end

  def print_command(cmd)
    p '*' * 15 + cmd + '*' * 15
  end

  def retrieve_binary_version
    _stdin, stdout, _stderr = Open3.popen3(@exe_path + ' -V')
    @binary_version = parse_version(stdout.gets(nil))
  rescue
    DEFAULT_BINARY_VERSION
  end

  def parse_version(version_info)
    match_data = /wkhtmltopdf\s*(\d*\.\d*\.\d*\w*)/.match(version_info)
    if match_data && (2 == match_data.length)
      Gem::Version.new(match_data[1])
    else
      DEFAULT_BINARY_VERSION
    end
  end

  def parse_options(options)
    [
      parse_extra(options),
      parse_others(options),
      parse_global(options),
      parse_outline(options.delete(:outline)),
      parse_header_footer(:header => options.delete(:header),
                          :footer => options.delete(:footer),
                          :layout => options[:layout]),
      parse_cover(options.delete(:cover)),
      parse_toc(options.delete(:toc)),
      parse_basic_auth(options)
    ].flatten
  end

  def parse_extra(options)
    return [] if options[:extra].nil?
    return options[:extra].split if options[:extra].respond_to?(:split)
    options[:extra]
  end

  def parse_basic_auth(options)
    if options[:basic_auth]
      user, passwd = Base64.decode64(options[:basic_auth]).split(':')
      ['--username', user, '--password', passwd]
    else
      []
    end
  end

  def make_option(name, value, type = :string)
    if value.is_a?(Array)
      return value.collect { |v| make_option(name, v, type) }
    end
    if type == :name_value
      parts = value.to_s.split(' ')
      ["--#{name.tr('_', '-')}", *parts]
    elsif type == :boolean
      if value
        ["--#{name.tr('_', '-')}"]
      else
        []
      end
    else
      ["--#{name.tr('_', '-')}", value.to_s]
    end
  end

  def valid_option(name)
    if binary_version < BINARY_VERSION_WITHOUT_DASHES
      "--#{name}"
    else
      name
    end
  end

  def make_options(options, names, prefix = '', type = :string)
    return [] if options.nil?
    names.collect do |o|
      if options[o].blank?
        []
      else
        make_option("#{prefix.blank? ? '' : prefix + '-'}#{o}",
                    options[o],
                    type)
      end
    end
  end

  def parse_header_footer(options)
    r = []
    [:header, :footer].collect do |hf|
      next if options[hf].blank?
      opt_hf = options[hf]
      r += make_options(opt_hf, [:center, :font_name, :left, :right], hf.to_s)
      r += make_options(opt_hf, [:font_size, :spacing], hf.to_s, :numeric)
      r += make_options(opt_hf, [:line], hf.to_s, :boolean)
      if options[hf] && options[hf][:content]
        @hf_tempfiles = [] unless defined?(@hf_tempfiles)
        @hf_tempfiles.push(tf = WickedPdfTempfile.new("wicked_#{hf}_pdf.html"))
        tf.write options[hf][:content]
        tf.flush
        options[hf][:html] = {}
        options[hf][:html][:url] = "file:///#{tf.path}"
      end
      unless opt_hf[:html].blank?
        r += make_option("#{hf}-html", opt_hf[:html][:url]) unless opt_hf[:html][:url].blank?
      end
    end unless options.blank?
    r
  end

  def parse_cover(argument)
    arg = argument.to_s
    return [] if arg.blank?
    # Filesystem path or URL - hand off to wkhtmltopdf
    if argument.is_a?(Pathname) || (arg[0, 4] == 'http')
      [valid_option('cover'), arg]
    else # HTML content
      @hf_tempfiles ||= []
      @hf_tempfiles << tf = WickedPdfTempfile.new('wicked_cover_pdf.html')
      tf.write arg
      tf.flush
      [valid_option('cover'), tf.path]
    end
  end

  def parse_toc(options)
    return [] if options.nil?
    r = [valid_option('toc')]
    unless options.blank?
      r += make_options(options, [:font_name, :header_text], 'toc')
      r += make_options(options, [:xsl_style_sheet])
      r += make_options(options, [:depth,
                                  :header_fs,
                                  :text_size_shrink,
                                  :l1_font_size,
                                  :l2_font_size,
                                  :l3_font_size,
                                  :l4_font_size,
                                  :l5_font_size,
                                  :l6_font_size,
                                  :l7_font_size,
                                  :level_indentation,
                                  :l1_indentation,
                                  :l2_indentation,
                                  :l3_indentation,
                                  :l4_indentation,
                                  :l5_indentation,
                                  :l6_indentation,
                                  :l7_indentation], 'toc', :numeric)
      r += make_options(options, [:no_dots,
                                  :disable_links,
                                  :disable_back_links], 'toc', :boolean)
      r += make_options(options, [:disable_dotted_lines,
                                  :disable_toc_links], nil, :boolean)
    end
    r
  end

  def parse_outline(options)
    r = []
    unless options.blank?
      r = make_options(options, [:outline], '', :boolean)
      r += make_options(options, [:outline_depth], '', :numeric)
    end
    r
  end

  def parse_margins(options)
    make_options(options, [:top, :bottom, :left, :right], 'margin', :numeric)
  end

  def parse_global(options)
    r = []
    unless options.blank?
      r += make_options(options, [:orientation,
                                  :dpi,
                                  :page_size,
                                  :page_width,
                                  :title])
      r += make_options(options, [:lowquality,
                                  :grayscale,
                                  :no_pdf_compression], '', :boolean)
      r += make_options(options, [:image_dpi,
                                  :image_quality,
                                  :page_height], '', :numeric)
      r += parse_margins(options.delete(:margin))
    end
    r
  end

  def parse_others(options)
    r = []
    unless options.blank?
      r += make_options(options, [:proxy,
                                  :username,
                                  :password,
                                  :encoding,
                                  :user_style_sheet,
                                  :viewport_size,
                                  :window_status])
      r += make_options(options, [:cookie,
                                  :post], '', :name_value)
      r += make_options(options, [:redirect_delay,
                                  :zoom,
                                  :page_offset,
                                  :javascript_delay], '', :numeric)
      r += make_options(options, [:book,
                                  :default_header,
                                  :disable_javascript,
                                  :enable_plugins,
                                  :disable_internal_links,
                                  :disable_external_links,
                                  :print_media_type,
                                  :disable_smart_shrinking,
                                  :use_xserver,
                                  :no_background,
                                  :no_stop_slow_scripts], '', :boolean)
    end
    r
  end

  def find_wkhtmltopdf_binary_path
    possible_locations = (ENV['PATH'].split(':') + %w(/usr/bin /usr/local/bin ~/bin)).uniq
    exe_path ||= WickedPdf.config[:exe_path] unless WickedPdf.config.empty?
    exe_path ||= begin
      detected_path = (defined?(Bundler) ? `bundle exec which wkhtmltopdf` : `which wkhtmltopdf`).chomp
      detected_path.present? && detected_path
    rescue
      nil
    end
    exe_path ||= possible_locations.map { |l| File.expand_path("#{l}/#{EXE_NAME}") }.find { |location| File.exist?(location) }
    exe_path || ''
  end
end
