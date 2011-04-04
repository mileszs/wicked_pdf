require 'tempfile'

class WickedPdfTempfile < Tempfile
  # Replaces Tempfile's +make_tmpname+ with one that honors file extensions.
  def make_tmpname(basename, n=0)
    extension = File.extname(basename)
    sprintf("%s_%d_%d%s", File.basename(basename, extension), $$, n, extension)
  end
end
 
