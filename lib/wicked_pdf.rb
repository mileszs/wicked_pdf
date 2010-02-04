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

  def pdf_from_string(string, options=nil)
    command_for_stdin_stdout = "#{@exe_path} #{options} - - -q" # -q for no errors on stdout
    p "*"*15 + command_for_stdin_stdout + "*"*15 if RAILS_ENV == 'development'
    Open3.popen3(command_for_stdin_stdout) do |stdin, stdout, stderr|
      stdin.write(string)
      stdin.close
      pdf = stdout.read
      raise "PDF could not be generated!\n#{stderr.read}" if pdf.length == 0
      pdf
    end
  end
end
