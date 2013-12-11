require 'tempfile'

class WickedPdfTempfile < Tempfile
  # ensures the Tempfile's filename always keeps its extension
  def initialize(filename, temp_dir=nil)
    temp_dir  ||= Dir.tmpdir
    extension = File.extname(filename)
    basename  = File.basename(filename, extension)
    super([basename, extension], temp_dir)
  end
end