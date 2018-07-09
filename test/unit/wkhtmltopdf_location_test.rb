

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
end
