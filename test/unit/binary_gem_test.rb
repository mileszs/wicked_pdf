require 'test_helper'
require 'rubygems/test_case'
require 'rubygems/commands/list_command'

class BinaryGemTest < Gem::TestCase
  def test_should_locate_binary_from_wkhtmltopdf_binary_edge
    spec = quick_gem('wkhtmltopdf-binary-edge', '0.12.5.0')
    cmd = Gem::Commands::ListCommand.new
    cmd.handle_options %w[wkhtmltopdf]

    use_ui @ui do
      puts cmd.execute
    end

    util_remove_gem(spec)
  end
end
