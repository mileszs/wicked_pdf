# wkhtml2pdf Ruby interface
# http://code.google.com/p/wkhtmltopdf/

require 'logger'
require 'digest/md5'
require 'rbconfig'
require RbConfig::CONFIG['target_os'] == 'mingw32' && !(RUBY_VERSION =~ /1.9/) ? 'win32/open3' : 'open3'
require 'active_support/core_ext/class/attribute_accessors'

begin
  require 'active_support/core_ext/object/blank'
rescue LoadError
  require 'active_support/core_ext/blank'
end

require 'wicked_pdf_version'
require 'wicked_pdf_railtie'
require 'wicked_pdf_tempfile'
require 'wicked_pdf_middleware'

class WickedPdf
  DEFAULT_BINARY_VERSION = Gem::Version.new('0.9.9')
  EXE_NAME = "wkhtmltopdf"
  @@config = {}
  cattr_accessor :config

  def initialize(wkhtmltopdf_binary_path = nil)
    @exe_path = wkhtmltopdf_binary_path || find_wkhtmltopdf_binary_path
    raise "Location of #{EXE_NAME} unknown" if @exe_path.empty?
    raise "Bad #{EXE_NAME}'s path" unless File.exists?(@exe_path)
    raise "#{EXE_NAME} is not executable" unless File.executable?(@exe_path)

    @binary_version = DEFAULT_BINARY_VERSION
  end

  def retreive_binary_version
    begin
      stdin, stdout, stderr = Open3.popen3(@exe_path + ' -V')
      @binary_version = parse_version(stdout.gets(nil))
    rescue StandardError
    end
  end

  def pdf_from_string(string, options={})
    if WickedPdf.config[:retreive_version]
      retreive_binary_version
    end

    temp_path = options.delete(:temp_path)
    string_file = WickedPdfTempfile.new("wicked_pdf.html", temp_path)
    string_file.write(string)
    string_file.close
    generated_pdf_file = WickedPdfTempfile.new("wicked_pdf_generated_file.pdf", temp_path)
    command = "\"#{@exe_path}\" #{'-q ' unless on_windows?}#{parse_options(options)} \"file:///#{string_file.path}\" \"#{generated_pdf_file.path}\" " # -q for no errors on stdout
    print_command(command) if in_development_mode?
    err = Open3.popen3(command) do |stdin, stdout, stderr|
      stderr.read
    end
    if return_file = options.delete(:return_file)
      return generated_pdf_file
    end
    generated_pdf_file.rewind
    generated_pdf_file.binmode
    pdf = generated_pdf_file.read
    raise "PDF could not be generated!\n Command Error: #{err}" if pdf and pdf.rstrip.length == 0
    pdf
  rescue Exception => e
    raise "Failed to execute:\n#{command}\nError: #{e}"
  ensure
    string_file.close! if string_file
    generated_pdf_file.close! if generated_pdf_file && !return_file
  end

  private

    def in_development_mode?
      return Rails.env == 'development' if defined?(Rails)
      RAILS_ENV == 'development' if defined?(RAILS_ENV)
    end

    def get_binary_version
      @binary_version
    end

    def on_windows?
      RbConfig::CONFIG['target_os'] == 'mingw32'
    end

    def print_command(cmd)
      p "*"*15 + cmd + "*"*15
    end

    def parse_version(version_info)
      match_data = /wkhtmltopdf\s*(\d*\.\d*\.\d*\w*)/.match(version_info)
      if (match_data && (2 == match_data.length))
        Gem::Version.new(match_data[1])
      else
        DEFAULT_BINARY_VERSION
      end
    end

    def parse_options(options)
      [
        parse_extra(options),
        parse_header_footer(:header => options.delete(:header),
                            :footer => options.delete(:footer),
                            :layout => options[:layout]),
        parse_toc(options.delete(:toc)),
        parse_outline(options.delete(:outline)),
        parse_margins(options.delete(:margin)),
        parse_others(options),
        parse_basic_auth(options)
      ].join(' ')
    end

    def parse_extra(options)
      options[:extra].nil? ? '' : options[:extra]
    end

    def parse_basic_auth(options)
      if options[:basic_auth]
        user, passwd = Base64.decode64(options[:basic_auth]).split(":")
        "--username '#{user}' --password '#{passwd}'"
      else
        ""
      end
    end

    def make_option(name, value, type=:string)
      if value.is_a?(Array)
        return value.collect { |v| make_option(name, v, type) }.join('')
      end
      "--#{name.gsub('_', '-')} " + case type
        when :boolean then ""
        when :numeric then value.to_s
        when :name_value then value.to_s
        else "\"#{value}\""
      end + " "
    end

    def make_options(options, names, prefix="", type=:string)
      names.collect {|o| make_option("#{prefix.blank? ? "" : prefix + "-"}#{o.to_s}", options[o], type) unless options[o].blank?}.join
    end

    def parse_header_footer(options)
      r=""
      [:header, :footer].collect do |hf|
        unless options[hf].blank?
          opt_hf = options[hf]
          r += make_options(opt_hf, [:center, :font_name, :left, :right], "#{hf.to_s}")
          r += make_options(opt_hf, [:font_size, :spacing], "#{hf.to_s}", :numeric)
          r += make_options(opt_hf, [:line], "#{hf.to_s}", :boolean)
          if options[hf] && options[hf][:content]
            @hf_tempfiles = [] if ! defined?(@hf_tempfiles)
            @hf_tempfiles.push( tf=WickedPdfTempfile.new("wicked_#{hf}_pdf.html") )
            tf.write options[hf][:content]
            tf.flush
            options[hf].delete(:content)
            options[hf][:html] = {}
            options[hf][:html][:url] = "file:///#{tf.path}"
          end
          unless opt_hf[:html].blank?
            r += make_option("#{hf.to_s}-html", opt_hf[:html][:url]) unless opt_hf[:html][:url].blank?
          end
        end
      end unless options.blank?
      r
    end

    def parse_toc(options)
      r = '--toc ' unless options.nil?
      unless options.blank?
        r += make_options(options, [ :font_name, :header_text], "toc")
        r +=make_options(options, [ :depth,
                                    :header_fs,
                                    :l1_font_size,
                                    :l2_font_size,
                                    :l3_font_size,
                                    :l4_font_size,
                                    :l5_font_size,
                                    :l6_font_size,
                                    :l7_font_size,
                                    :l1_indentation,
                                    :l2_indentation,
                                    :l3_indentation,
                                    :l4_indentation,
                                    :l5_indentation,
                                    :l6_indentation,
                                    :l7_indentation], "toc", :numeric)
        r +=make_options(options, [ :no_dots,
                                    :disable_links,
                                    :disable_back_links], "toc", :boolean)
      end
      return r
    end

    def parse_outline(options)
      unless options.blank?
        r = make_options(options, [:outline], "", :boolean)
        r +=make_options(options, [:outline_depth], "", :numeric)
      end
    end

    def parse_margins(options)
      make_options(options, [:top, :bottom, :left, :right], "margin", :numeric) unless options.blank?
    end

    def parse_others(options)
      unless options.blank?
        r = make_options(options, [ :orientation,
                                    :page_size,
                                    :page_width,
                                    :page_height,
                                    :proxy,
                                    :username,
                                    :password,
                                    :cover,
                                    :dpi,
                                    :encoding,
                                    :user_style_sheet])
        r +=make_options(options, [ :cookie,
                                    :post], "", :name_value)
        r +=make_options(options, [ :redirect_delay,
                                    :zoom,
                                    :page_offset,
                                    :javascript_delay], "", :numeric)
        r +=make_options(options, [ :book,
                                    :default_header,
                                    :disable_javascript,
                                    :grayscale,
                                    :lowquality,
                                    :enable_plugins,
                                    :disable_internal_links,
                                    :disable_external_links,
                                    :print_media_type,
                                    :disable_smart_shrinking,
                                    :use_xserver,
                                    :no_background], "", :boolean)
      end
    end

    def find_wkhtmltopdf_binary_path
      possible_locations = (ENV['PATH'].split(':')+%w[/usr/bin /usr/local/bin ~/bin]).uniq
      exe_path ||= WickedPdf.config[:exe_path] unless WickedPdf.config.empty?
      exe_path ||= begin
        (defined?(Bundler) ? `bundle exec which wkhtmltopdf` : `which wkhtmltopdf`).chomp
      rescue Exception => e
        nil
      end
      exe_path ||= possible_locations.map{|l| File.expand_path("#{l}/#{EXE_NAME}") }.find{|location| File.exists? location}
      exe_path || ''
    end
end
