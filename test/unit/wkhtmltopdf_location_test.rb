require 'test_helper'
require 'rubygems/test_case'
require 'rubygems/commands/list_command'

class WkhtmltopdfLocationTest < ActiveSupport::TestCase
  setup do
    @saved_config = WickedPdf.config
    WickedPdf.config = {}
  end

  teardown do
    WickedPdf.config = @saved_config
  end

  class BinaryGemsTest < Gem::TestCase
    def test_should_locate_binary_from_wkhtmltopdf_binary_edge
      puts Gem::Commands::ListCommand.new name: /wkhtmltopdf/
      spec = quick_gem('wkhtmltopdf-binary-edge', '0.12.0')
      util_remove_gem(spec)
    end
  end

  test 'should correctly locate wkhtmltopdf without bundler' do
    bundler_module = Bundler
    Object.send(:remove_const, :Bundler)

    assert_nothing_raised do
      WickedPdf.new
    end

    Object.const_set(:Bundler, bundler_module)
  end

  test 'should correctly locate wkhtmltopdf with bundler' do
    assert_nothing_raised do
      WickedPdf.new
    end
  end

  class LocationNonWritableTest < ActiveSupport::TestCase
    setup do
      @saved_config = WickedPdf.config
      WickedPdf.config = {}

      @old_home = ENV['HOME']
      ENV['HOME'] = '/not/a/writable/directory'
    end

    teardown do
      WickedPdf.config = @saved_config
      ENV['HOME'] = @old_home
    end

    test 'should correctly locate wkhtmltopdf with bundler while HOME is set to a non-writable directory' do
      assert_nothing_raised do
        WickedPdf.new
      end
    end
  end
end
