# frozen_string_literal: true

class WickedPdf
  module Progress
    require 'pty' if RbConfig::CONFIG['target_os'] !~ /mswin|mingw/ && RUBY_ENGINE != 'truffleruby' # no support for windows and truffleruby
    require 'English'

    def track_progress?(options)
      options[:progress] && !(on_windows? || RUBY_ENGINE == 'truffleruby')
    end

    def invoke_with_progress(command, options)
      output = []
      begin
        PTY.spawn(command.join(' ')) do |stdout, _stdin, pid|
          begin
            stdout.sync
            stdout.each_line("\r") do |line|
              output << line.chomp
              options[:progress].call(line) if options[:progress]
            end
          rescue Errno::EIO # rubocop:disable Lint/HandleExceptions
            # child process is terminated, this is expected behaviour
          ensure
            ::Process.wait pid
          end
        end
      rescue PTY::ChildExited
        puts 'The child process exited!'
      end
      err = output.join('\n')
      raise "#{command} failed (exitstatus 0). Output was: #{err}" unless $CHILD_STATUS && $CHILD_STATUS.exitstatus.zero?
    end
  end
end
