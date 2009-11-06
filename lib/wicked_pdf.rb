# wkhtml2pdf Ruby interface
# http://code.google.com/p/wkhtmltopdf/

require 'logger'
require 'digest/md5'
require 'open3'

class WickedPdf
  attr_accessor :exe_path, :log_file, :logger

  def initialize(wkhtmltopdf_binary = nil)
    @exe_path = wkhtmltopdf_binary 
    @exe_path ||= `which wkhtmltopdf`.chomp
    @log_file = "#{RAILS_ROOT}/log/wkhtmltopdf.log"
    @logger   = RAILS_DEFAULT_LOGGER
  end

  def pdf_from_string(string)
    command_for_stdin_stdout = @exe_path.strip + " - - -q" # -q for no errors on stdout
    Open3.popen3(command_for_stdin_stdout) do |stdin, stdout, stderr|
      stdin.write(string)
      stdin.close
      stdout.read
    end
  end
end
