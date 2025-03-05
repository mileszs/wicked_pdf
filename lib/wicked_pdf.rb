# frozen_string_literal: true

# wkhtml2pdf Ruby interface
# http://wkhtmltopdf.org/

require 'logger'
require 'digest/md5'
require 'rbconfig'
require 'open3'
require 'ostruct'

require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/object/blank'

require 'wicked_pdf/version'
require 'wicked_pdf/railtie'
require 'wicked_pdf/option_parser'
require 'wicked_pdf/tempfile'
require 'wicked_pdf/binary'
require 'wicked_pdf/middleware'
require 'wicked_pdf/progress'

class WickedPdf
  DEFAULT_BINARY_VERSION = Gem::Version.new('0.9.9')
  @@config = {}
  cattr_accessor :config, :silence_deprecations

  include Progress

  def self.config=(config)
    ::Kernel.warn 'WickedPdf.config= is deprecated and will be removed in future versions. Use WickedPdf.configure instead.' unless @@silence_deprecations

    @@config = config
  end

  def self.configure
    config = OpenStruct.new(@@config)
    yield config

    @@config.merge! config.to_h
  end

  def self.clear_config
    @@config = {}
  end

  def initialize(wkhtmltopdf_binary_path = nil)
    @binary = Binary.new(wkhtmltopdf_binary_path, DEFAULT_BINARY_VERSION)
  end

  def binary_version
    @binary.version
  end

  def pdf_from_html_file(filepath, options = {})
    pdf_from_url("file:///#{filepath}", options)
  end

  def pdf_from_string(string, options = {})
    options = options.dup
    options.merge!(WickedPdf.config) { |_key, option, _config| option }
    string_file = WickedPdf::Tempfile.new('wicked_pdf.html', options[:temp_path])
    string_file.write_in_chunks(string)
    pdf_from_html_file(string_file.path, options)
  ensure
    if options[:delete_temporary_files] && string_file
      string_file.close!
    elsif string_file
      string_file.close
    end
  end

  def pdf_from_url(url, options = {}) # rubocop:disable Metrics/CyclomaticComplexity
    # merge in global config options
    options.merge!(WickedPdf.config) { |_key, option, _config| option }
    generated_pdf_file = WickedPdf::Tempfile.new('wicked_pdf_generated_file.pdf', options[:temp_path])
    command = [@binary.path]
    command.unshift(@binary.xvfb_run_path) if options[:use_xvfb]
    command += option_parser.parse(options)
    command << url
    command << generated_pdf_file.path.to_s

    print_command(command.inspect) if in_development_mode?

    if track_progress?(options)
      invoke_with_progress(command, options)
    else
      _out, err, status = Open3.capture3(*command)
      err = [status.to_s, err].join("\n") if !err.empty? || !status.success?
    end
    if options[:return_file]
      return_file = options.delete(:return_file)
      return generated_pdf_file
    end

    pdf = generated_pdf_file.read_in_chunks

    raise "Error generating PDF\n Command Error: #{err}" if options[:raise_on_all_errors] && !err.empty?
    raise "PDF could not be generated!\n Command Error: #{err}" if pdf && pdf.rstrip.empty?

    pdf
  rescue StandardError => e
    raise "Failed to execute:\n#{command}\nError: #{e}"
  ensure
    clean_temp_files
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

  def option_parser
    @option_parser ||= OptionParser.new(binary_version)
  end

  def clean_temp_files
    return unless option_parser.hf_tempfiles.present?

    option_parser.hf_tempfiles.each { |file| File.delete(file) }
  end
end
