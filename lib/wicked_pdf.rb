# wkhtml2pdf Ruby interface
# http://code.google.com/p/wkhtmltopdf/

require 'logger'
require 'digest/md5'
require 'open3'

class WickedPdf
  def initialize(wkhtmltopdf_binary_path = nil)
    @exe_path = wkhtmltopdf_binary_path
    @exe_path ||= WICKED_PDF[:exe_path] unless WICKED_PDF.empty?
    @exe_path ||= `which wkhtmltopdf`.chomp
    raise "Location of wkhtmltopdf unknown" if @exe_path.empty?
    raise "Bad wkhtmltopdf's path" unless File.exists?(@exe_path)
    raise "Wkhtmltopdf is not executable" unless File.executable?(@exe_path)
  end

  def pdf_from_string(string, options={})
    command_for_stdin_stdout = "#{@exe_path} #{parse_options(options)} - - -q" # -q for no errors on stdout
    p "*"*15 + command_for_stdin_stdout + "*"*15 if RAILS_ENV == 'development'
    Open3.popen3(command_for_stdin_stdout) do |stdin, stdout, stderr|
      stdin.write(string)
      stdin.close
      pdf = stdout.read
      raise "PDF could not be generated!\n#{stderr.read}" if pdf.length == 0
      pdf
    end
  end

  private
  def parse_options opts
    "#{parse_header_footer(:header => opts.delete(:header), :footer => opts.delete(:footer), :layout => opts[:layout])} " + \
    "#{parse_toc(opts.delete(:toc))} #{parse_outline(opts.delete(:outline))} #{parse_margins(opts.delete(:margin))} #{parse_others(opts)} "
  end

  def make_option name, value, type=:string
    "--#{name.gsub('_', '-')} " + case type
      when :boolean: ""
      when :numeric: value.to_s
      else "'#{value}'"
    end + " "
  end

  def make_options opts, names, prefix="", type=:string
    names.collect {|o| make_option("#{prefix.blank? ? "" : prefix + "-"}#{o.to_s}", opts[o], type) unless opts[o].blank?}.join
  end

  def parse_header_footer opts
    r=""
    [:header, :footer].collect do |hf|
      unless opts[hf].blank?
        opt_hf = opts[hf]
        r += make_options(opt_hf, [:center, :font_name, :left, :right], "#{hf.to_s}")
        r += make_options(opt_hf, [:font_size, :spacing], "#{hf.to_s}", :numeric)
        r += make_options(opt_hf, [:line], "#{hf.to_s}", :boolean)
        unless opt_hf[:html].blank?
          r += make_option("#{hf.to_s}-html", opt_hf[:html][:url]) unless opt_hf[:html][:url].blank?
        end
      end
    end unless opts.blank?
    r
  end

  def parse_toc opts
    unless opts.blank?
      r = make_options(opts, [:font_name, :header_text], "toc")
      r += make_options(opts, [:depth, :header_fs, :l1_font_size, :l2_font_size, :l3_font_size, :l4_font_size, :l5_font_size, :l6_font_size, :l7_font_size, :l1_indentation, :l2_indentation, :l3_indentation, :l4_indentation, :l5_indentation, :l6_indentation, :l7_indentation], "toc", :numeric)
      r + make_options(opts, [:no_dots, :disable_links, :disable_back_links], "toc", :boolean)
    end
  end

  def parse_outline opts
    unless opts.blank?
      r = make_options(opts, [:outline], "", :boolean)
      r + make_options(opts, [:outline_depth], "", :numeric)
    end
  end

  def parse_margins opts
    make_options(opts, [:top, :bottom, :left, :right], "margin", :numeric) unless opts.blank?
  end

  def parse_others opts
    unless opts.blank?
      r = make_options(opts, [:orientation, :page_size, :proxy, :username, :password, :cover, :dpi, :encoding, :user_style_sheet])
      r += make_options(opts, [:redirect_delay, :zoom, :page_offset], "", :numeric)
      r + make_options(opts, [:book, :default_header, :disable_javascript, :greyscale, :lowquality, :enable_plugins, :disable_internal_links, :disable_external_links, :print_media_type, :disable_smart_shrinking, :use_xserver, :no_background], "", :boolean)
    end
  end
end
