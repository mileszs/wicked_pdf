require 'test_helper'
require 'action_view/test_case'

class WickedPdfHelperAssetsTest < ActionView::TestCase

  include WickedPdfHelper::Assets

  if Rails::VERSION::MAJOR == 4
    test 'wicked_pdf_asset_path should return an url when assets are served by an asset server' do
      expects(:asset_pathname => 'http://assets.domain.com/dummy.png')
      assert_equal 'http://assets.domain.com/dummy.png', wicked_pdf_asset_path('dummy.png')
    end
  end

end
