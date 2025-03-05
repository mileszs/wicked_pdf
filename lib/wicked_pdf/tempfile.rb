# frozen_string_literal: true

require 'tempfile'
require 'stringio'

class WickedPdf
  class Tempfile < ::Tempfile
    def initialize(filename, temp_dir = nil)
      temp_dir ||= Dir.tmpdir
      extension = File.extname(filename)
      basename = File.basename(filename, extension)
      super([basename, extension], temp_dir)
    end

    def write_in_chunks(input_string)
      binmode
      string_io = StringIO.new(input_string)
      write(string_io.read(chunk_size)) until string_io.eof?
      close
      self
    rescue Errno::EINVAL => e
      raise e, file_too_large_message
    end

    def read_in_chunks
      rewind
      binmode
      chunks = []
      chunks << read(chunk_size) until eof?
      chunks.join
    rescue Errno::EINVAL => e
      raise e, file_too_large_message
    end

    private

    def chunk_size
      1024 * 1024
    end

    def file_too_large_message
      'The HTML file is too large! Try reducing the size or using the return_file option instead.'
    end
  end
end
