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
        PTY.spawn(*command) do |stdout, _stdin, pid|
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
      err = output.join("\n")
      exitstatus = $CHILD_STATUS && $CHILD_STATUS.exitstatus
      raise "#{command} failed (exitstatus #{exitstatus}). Output was: #{err}" unless exitstatus == 0

      err
    end
  end
end
