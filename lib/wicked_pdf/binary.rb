# frozen_string_literal: true

class WickedPdf
  class Binary
    EXE_NAME = 'wkhtmltopdf'

    attr_reader :path, :default_version

    def initialize(binary_path, default_version = WickedPdf::DEFAULT_BINARY_VERSION)
      @path = binary_path || find_binary_path
      @default_version = default_version

      raise "Location of #{EXE_NAME} unknown" if @path.empty?
      raise "Bad #{EXE_NAME}'s path: #{@path}" unless File.exist?(@path)
      raise "#{EXE_NAME} is not executable" unless File.executable?(@path)
    end

    def version
      @version ||= retrieve_binary_version
    end

    def parse_version_string(version_info)
      match_data = /wkhtmltopdf\s*(\d*\.\d*\.\d*\w*)/.match(version_info)
      if match_data && (match_data.length == 2)
        Gem::Version.new(match_data[1])
      else
        default_version
      end
    end

    def xvfb_run_path
      path = possible_binary_locations.map { |l| File.expand_path("#{l}/xvfb-run") }.find { |location| File.exist?(location) }
      raise StandardError, 'Could not find binary xvfb-run on the system.' unless path

      path
    end

    private

    def retrieve_binary_version
      _stdin, stdout, _stderr = Open3.popen3(@path + ' -V')
      parse_version_string(stdout.gets(nil))
    rescue StandardError
      default_version
    end

    def find_binary_path
      exe_path ||= WickedPdf.config[:exe_path] unless WickedPdf.config.empty?
      exe_path ||= possible_which_path
      exe_path ||= possible_binary_locations.map { |l| File.expand_path("#{l}/#{EXE_NAME}") }.find { |location| File.exist?(location) }
      exe_path || ''
    end

    def possible_which_path
      detected_path = (defined?(Bundler) ? Bundler.which('wkhtmltopdf') : `which wkhtmltopdf`).chomp
      detected_path.present? && detected_path
    rescue StandardError
      nil
    end

    def possible_binary_locations
      possible_locations = (ENV['PATH'].split(':') + %w[/usr/bin /usr/local/bin]).uniq
      possible_locations += %w[~/bin] if ENV.key?('HOME')
      possible_locations
    end
  end
end
