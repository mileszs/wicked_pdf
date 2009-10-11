# wkhtml2pdf Ruby interface
# http://code.google.com/p/wkhtmltopdf/

require 'logger'
require 'digest/md5'
require 'tempfile'

class WickedPdf
  attr_accessor :exe_path, :log_file, :logger

  def initialize(wkhtmltopdf_binary = nil)
    @exe_path = wkhtmltopdf_binary 
    @exe_path ||= `which wkhtmltopdf`.chomp
    @log_file = "#{RAILS_ROOT}/log/wkhtmltopdf.log"
    @logger   = RAILS_DEFAULT_LOGGER
  end

  def pdf_from_string(string)
    path = @exe_path
    # Don't output errors to standard out
    path << ' -q'

    logger.info "\n\n-- wkhtmltopdf command --"
    tmp_file = Tempfile.new(['wicked_pdf', '.html'], 'tmp')
    tmp_file.write(string)
    tmp_file.close
    path = path + ' ' + tmp_file.path + ' -'
    tmp_file.unlink

    logger.info path
    logger.info ''

    pdf = `#{path}`
    pdf
  end
end
