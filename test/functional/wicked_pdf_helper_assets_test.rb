require 'test_helper'
require 'action_view/test_case'

class WickedPdfHelperAssetsTest < ActionView::TestCase

  include WickedPdfHelper::Assets

  if Rails::VERSION::MAJOR == 4
    test 'wicked_pdf_asset_path should return an url when assets are served by an asset server' do
      expects(:asset_pathname => 'http://assets.domain.com/dummy.png')
      assert_equal 'http://assets.domain.com/dummy.png', wicked_pdf_asset_path('dummy.png')
    end

    test 'wicked_pdf_asset_path should return an url with a protocol when assets are served by an asset server with relative urls' do
      expects(:asset_path => '//assets.domain.com/dummy.png')
      expects("precompiled_asset?" => true)
      assert_equal 'http://assets.domain.com/dummy.png', wicked_pdf_asset_path('dummy.png')
    end

    test 'wicked_pdf_asset_path should return a path when assets are precompiled' do
      expects("precompiled_asset?" => false)
      path = wicked_pdf_asset_path('application.css')

      assert path.include?("/assets/stylesheets/application.css")
      assert path.include?("file://")
    end
  end

end
