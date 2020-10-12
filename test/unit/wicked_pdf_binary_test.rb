require 'test_helper'

class WickedPdfBinaryTest < ActiveSupport::TestCase
  test 'should extract old wkhtmltopdf version' do
    version_info_sample = "Name:\n  wkhtmltopdf 0.9.9\n\nLicense:\n  Copyright (C) 2008,2009 Wkhtmltopdf Authors.\n\n\n\n  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n  This is free software: you are free to change and redistribute it. There is NO\n  WARRANTY, to the extent permitted by law.\n\nAuthors:\n  Written by Jakob Truelsen. Patches by Mrio Silva, Benoit Garret and Emmanuel\n  Bouthenot.\n"
    assert_equal WickedPdf::DEFAULT_BINARY_VERSION, binary.parse_version_string(version_info_sample)
  end

  test 'should extract new wkhtmltopdf version' do
    version_info_sample = "Name:\n  wkhtmltopdf 0.11.0 rc2\n\nLicense:\n  Copyright (C) 2010 wkhtmltopdf/wkhtmltoimage Authors.\n\n\n\n  License LGPLv3+: GNU Lesser General Public License version 3 or later\n  <http://gnu.org/licenses/lgpl.html>. This is free software: you are free to\n  change and redistribute it. There is NO WARRANTY, to the extent permitted by\n  law.\n\nAuthors:\n  Written by Jan Habermann, Christian Sciberras and Jakob Truelsen. Patches by\n  Mehdi Abbad, Lyes Amazouz, Pascal Bach, Emmanuel Bouthenot, Benoit Garret and\n  Mario Silva."
    assert_equal Gem::Version.new('0.11.0'), binary.parse_version_string(version_info_sample)
  end

  test 'should extract wkhtmltopdf version with nondigit symbols' do
    version_info_sample = "Name:\n  wkhtmltopdf 0.10.4b\n\nLicense:\n  Copyright (C) 2008,2009 Wkhtmltopdf Authors.\n\n\n\n  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n  This is free software: you are free to change and redistribute it. There is NO\n  WARRANTY, to the extent permitted by law.\n\nAuthors:\n  Written by Jakob Truelsen. Patches by Mrio Silva, Benoit Garret and Emmanuel\n  Bouthenot.\n"
    assert_equal Gem::Version.new('0.10.4b'), binary.parse_version_string(version_info_sample)
  end

  test 'should fallback to default version on parse error' do
    assert_equal WickedPdf::DEFAULT_BINARY_VERSION, binary.parse_version_string('')
  end

  def binary(path = nil)
    WickedPdf::Binary.new(path)
  end
end
