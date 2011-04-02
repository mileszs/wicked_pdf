# wkhtml2pdf Ruby interface
# http://code.google.com/p/wkhtmltopdf/

require 'logger'
require 'digest/md5'
require 'open3'
require 'active_support/core_ext/class/attribute_accessors'

require 'wicked_pdf_railtie'

class WickedPdf
  @@config = {}
  cattr_accessor :config

  def initialize(wkhtmltopdf_binary_path = nil)
    @exe_path = wkhtmltopdf_binary_path
    @exe_path ||= WickedPdf.config[:exe_path] unless WickedPdf.config.empty?
    @exe_path ||= `which wkhtmltopdf`.chomp
    raise "Location of wkhtmltopdf unknown" if @exe_path.empty?
    raise "Bad wkhtmltopdf's path" unless File.exists?(@exe_path)
    raise "Wkhtmltopdf is not executable" unless File.executable?(@exe_path)
  end

  def pdf_from_string(string, options={})
    command_for_stdin_stdout = "#{@exe_path} #{parse_options(options)} -q - - " # -q for no errors on stdout
    p "*"*15 + command_for_stdin_stdout + "*"*15 unless defined?(Rails) and Rails.env != 'development'
    pdf, err = begin
      Open3.popen3(command_for_stdin_stdout) do |stdin, stdout, stderr|
        stdin.write(string)
        stdin.close
        [stdout.read, stderr.read]
      end
    rescue Exception => e
      raise "Failed to execute #{@exe_path}: #{e}"
    end
    raise "PDF could not be generated!\n#{err}" if pdf and pdf.length == 0
    pdf
  end

  private
  def parse_options(options)
    [
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

  def parse_basic_auth(options)
    if options[:basic_auth]
      user, passwd = Base64.decode64(options[:basic_auth]).split(":")
      "--username #{user} --password #{passwd} "
    else
      ""
    end
  end

  def make_option(name, value, type=:string)
    "--#{name.gsub('_', '-')} " + case type
      when :boolean then ""
      when :numeric then value.to_s
      else "'#{value}'"
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
        unless opt_hf[:html].blank?
          r += make_option("#{hf.to_s}-html", opt_hf[:html][:url]) unless opt_hf[:html][:url].blank?
        end
      end
    end unless options.blank?
    r
  end

  def parse_toc(options)
    unless options.blank?
      r = make_options(options, [ :font_name, :header_text], "toc")
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
      r +=make_options(options, [ :redirect_delay,
                                  :zoom,
                                  :page_offset], "", :numeric)
      r +=make_options(options, [ :book,
                                  :default_header,
                                  :disable_javascript,
                                  :greyscale,
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
end
