# wkhtml2pdf Ruby interface
# http://code.google.com/p/wkhtmltopdf/

require 'logger'
require 'digest/md5'
require 'open3'

class WickedPdf

  def initialize(wkhtmltopdf_binary_path = nil)
    @exe_path = wkhtmltopdf_binary_path 
    @exe_path ||= `which wkhtmltopdf`.chomp
    raise "Location of wkhtmltopdf unknown" if @exe_path.length == 0
  end

  def pdf_from_string(string)
    command_for_stdin_stdout = @exe_path + " - - -q" # -q for no errors on stdout
    Open3.popen3(command_for_stdin_stdout) do |stdin, stdout, stderr|
      stdin.write(string)
      stdin.close
      pdf = stdout.read
      raise "PDF could not be generated!\n#{stderr.read}" if pdf.length == 0
      pdf
    end
  end
end
