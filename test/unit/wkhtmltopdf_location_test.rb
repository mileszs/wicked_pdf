require 'test_helper'
require 'rubygems/test_case'

class WkhtmltopdfLocationTest < ActiveSupport::TestCase
  setup do
    @saved_config = WickedPdf.config
    WickedPdf.config = {}
  end

  teardown do
    WickedPdf.config = @saved_config
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

  # These tests involve rubygems and their presence on a host.
  # By inheriting from Gem::TestCase, all interaction with the actual
  # rubygems is mocked. For these tests, gems will be created in a
  # temporary location and will automatically be removed afterwards.
  class BundledExecutableTest < Gem::TestCase
    def test_should_locate_binary_from_wkhtmltopdf_binary_edge
      spec = executable_gem 'wkhtmltopdf-binary-edge', '0.12.1'

      wicked_pdf = WickedPdf.new
      assert_equal '0.12.1', wicked_pdf.binary_version.to_s
    end

    def test_should_locate_binary_from_wkhtmltopdf_heroku
      spec = executable_gem 'wkhtmltopdf-heroku', '0.12.2'

      wicked_pdf = WickedPdf.new
      assert_equal '0.12.2', wicked_pdf.binary_version.to_s
    end

    def test_should_locate_binary_from_wkhtmltopdf_binary_the_legend
      spec = executable_gem 'wkhtmltopdf-heroku', '0.12.3'

      wicked_pdf = WickedPdf.new
      assert_equal '0.12.3', wicked_pdf.binary_version.to_s
    end

    private

    # Create and install a mock rubygem with a stub wkhtmltopdf executable.
    #   example: executable_gem 'wkhtmltopdf-binary', '0.12.5'
    # The executable version will be equal to the rubygem version.
    def executable_gem(name, version)
      spec = quick_gem(name, version) do |s|
        s.executables = ['wkhtmltopdf']
        s.files = ['bin/wkhtmltopdf']
      end

      write_file File.join('gems', spec.full_name, 'bin', 'wkhtmltopdf') do |file|
        file.puts "#!/bin/sh\necho 'wkhtmltopdf #{version}'"
        file.chmod(0700)
      end

      spec
    end
  end
end
