# wkhtml2pdf Ruby interface
# http://wkhtmltopdf.org/

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
require 'wicked_pdf/option_parser'
require 'wicked_pdf/tempfile'
require 'wicked_pdf/middleware'
require 'wicked_pdf/progress'

class WickedPdf
  DEFAULT_BINARY_VERSION = Gem::Version.new('0.9.9')
  EXE_NAME = 'wkhtmltopdf'.freeze
  @@config = {}
  cattr_accessor :config
  attr_accessor :binary_version

  include Progress

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
    command += parse_options(options)
    command << url
    command << generated_pdf_file.path.to_s

    print_command(command.inspect) if in_development_mode?

    if track_progress?(options)
      invoke_with_progress(command, options)
    else
      err = Open3.popen3(*command) do |_stdin, _stdout, stderr|
        stderr.read
      end
    end
    if options[:return_file]
      return_file = options.delete(:return_file)
      return generated_pdf_file
    end
    generated_pdf_file.rewind
    generated_pdf_file.binmode
    pdf = generated_pdf_file.read
    raise "Error generating PDF\n Command Error: #{err}" if options[:raise_on_all_errors] && !err.empty?
    raise "PDF could not be generated!\n Command Error: #{err}" if pdf && pdf.rstrip.empty?
    pdf
  rescue StandardError => e
    raise "Failed to execute:\n#{command}\nError: #{e}"
  ensure
    generated_pdf_file.close! if generated_pdf_file && !return_file
  end

  private

  def in_development_mode?
    return Rails.env == 'development' if defined?(Rails.env)
    RAILS_ENV == 'development' if defined?(RAILS_ENV)
  end

  def on_windows?
    RbConfig::CONFIG['target_os'] =~ /mswin|mingw/
  end

  def print_command(cmd)
    Rails.logger.debug '[wicked_pdf]: ' + cmd
  end

  def retrieve_binary_version
    _stdin, stdout, _stderr = Open3.popen3(@exe_path + ' -V')
    @binary_version = parse_version(stdout.gets(nil))
  rescue StandardError
    DEFAULT_BINARY_VERSION
  end

  def parse_version(version_info)
    match_data = /wkhtmltopdf\s*(\d*\.\d*\.\d*\w*)/.match(version_info)
    if match_data && (match_data.length == 2)
      Gem::Version.new(match_data[1])
    else
      DEFAULT_BINARY_VERSION
    end
  end

  def parse_options(options)
    OptionParser.new(binary_version).parse(options)
  end

  def find_wkhtmltopdf_binary_path
    possible_locations = (ENV['PATH'].split(':') + %w[/usr/bin /usr/local/bin]).uniq
    possible_locations += %w[~/bin] if ENV.key?('HOME')
    exe_path ||= WickedPdf.config[:exe_path] unless WickedPdf.config.empty?
    exe_path ||= begin
      detected_path = (defined?(Bundler) ? Bundler.which('wkhtmltopdf') : `which wkhtmltopdf`).chomp
      detected_path.present? && detected_path
    rescue StandardError
      nil
    end
    exe_path ||= possible_locations.map { |l| File.expand_path("#{l}/#{EXE_NAME}") }.find { |location| File.exist?(location) }
    exe_path || ''
  end
end
