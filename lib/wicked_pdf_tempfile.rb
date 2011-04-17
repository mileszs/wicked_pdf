require 'tempfile'

class WickedPdfTempfile < Tempfile
  # Replaces Tempfile's +make_tmpname+ with one that honors file extensions.
  def make_tmpname(basename, n)
    extension = File.extname(basename)
    sprintf("%s_%d_%d%s", File.basename(basename, extension), $$, n.to_i, extension)
  end
end

