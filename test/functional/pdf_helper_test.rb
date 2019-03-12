require 'test_helper'

module ActionController
  class Base
    def render_to_string(opts = {})
      opts.to_s
    end

    def self.alias_method_chain(_target, _feature); end
  end
end

module ActionControllerMock
  class Base
    def render(_)
      [:base]
    end

    def render_to_string; end

    def self.after_action(_); end
  end
end

class PdfHelperTest < ActionController::TestCase
  module SomePatch
    def render(_)
      super.tap do |s|
        s << :patched
      end
    end
  end

  def setup
    @ac = ActionController::Base.new
  end

  def teardown
    @ac = nil
  end

  test 'should prerender header and footer :template options' do
    options = @ac.send(:prerender_header_and_footer,
                       :header => { :html => { :template => 'hf.html.erb' } })
    assert_match %r{^file:\/\/\/.*wicked_header_pdf.*\.html}, options[:header][:html][:url]
  end

  test 'should not interfere with already prepended patches' do
    # Emulate railtie
    if Rails::VERSION::MAJOR >= 5
      # this spec tests the following:
      # if another gem prepends a render method to ActionController::Base
      # before wicked_pdf does, does calling render trigger an infinite loop?
      # this spec fails with 6392bea1fe3a41682dfd7c20fd9c179b5a758f59 because PdfHelper
      # aliases the render method prepended by the other gem to render_without_pdf, then
      # base_evals its own definition of render, which calls render_with_pdf -> render_without_pdf.
      # If the other gem uses the prepend inhertinance pattern (calling super instead of aliasing),
      # when it calls super it calls the base_eval'd version of render instead of going up the
      # inheritance chain, causing an infinite loop.

      # This fiddling with consts is required to get around the fact that PdfHelper checks
      # that it is being prepended to ActionController::Base
      OriginalBase = ActionController::Base
      ActionController.send(:remove_const, :Base)
      ActionController.const_set(:Base, ActionControllerMock::Base)

      # Emulate another gem being loaded before wicked
      ActionController::Base.prepend(SomePatch)
      ActionController::Base.prepend(::WickedPdf::PdfHelper)

      begin
        # test that wicked's render method is actually called
        ac = ActionController::Base.new
        ac.expects(:render_with_wicked_pdf)
        ac.render(:cats)

        # test that calling render does not trigger infinite loop
        ac = ActionController::Base.new
        assert_equal [:base, :patched], ac.render(:cats)
      rescue SystemStackError
        assert_equal true, false # force spec failure
      ensure
        ActionController.send(:remove_const, :Base)
        ActionController.const_set(:Base, OriginalBase)
      end
    end
  end

  test 'should call after_action instead of after_filter when able' do
    ActionController::Base.expects(:after_filter).with(:clean_temp_files).never
    ActionController::Base.expects(:after_action).with(:clean_temp_files).once
    ActionController::Base.class_eval do
      include ::WickedPdf::PdfHelper
    end
  end
end
