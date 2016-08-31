# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.0] - 2016-09-30
### Added
- Support Rails 5.x and Sprockets 3.x
- Support `window_status: 'somestring'` option, to instruct wkhtmltopdf to wait until the browser `window.status` is equal to the supplied string. This can be useful to force rendering to wait [as explained quite well here](https://spin.atomicobject.com/2015/08/29/ember-app-done-loading/)
- Support `no_stop_slow_scripts: true` to let slow running scripts delay rendering

### Changed
- [Improved error handling](https://github.com/mileszs/wicked_pdf/pull/543)
- [Namespace helper classes under WickedPdf namespace](https://github.com/mileszs/wicked_pdf/pull/538)
- [Changes to asset finding to support Rails 5](https://github.com/mileszs/wicked_pdf/pull/561)

## [1.0.6] - 2016-04-04
### Changed
- Revert shellescaping of options. The fix was causing more issues than it solved (like "[page] of [topage]" being escaped, and thus not parsed by `wkhtmltopdf`). See #514 for details.

## [1.0.5] - 2016-03-28
### Changed
- Numerous RuboCop style violation fixes, spelling errors, and test-setup issues from [indyrb.org](http://indyrb.org/) hack night. Thank you all for your contributions!

### Fixed
- Shellescape options. A stray quote in `header` or `footer` would cause PDF to fail to generate, and this should close down many potential attack vectors if you allow user-supplied values to be passed into `wicked_pdf` render options.

## [1.0.4] - 2016-01-26
### Changed
- Check that logger responds to info before calling it. It was possible to have a `logger` method defined as a controller helper that would override `Rails.logger`.

### Fixed
- [Issue with Sprockets 3.0](https://github.com/mileszs/wicked_pdf/issues/476) where an asset referenced in a stylesheet not existing would raise an exception `read_asset` on nil.

## [1.0.3] - 2015-12-02
### Changed
- Revert default DPI. Some installs of `wkhtmltopdf` would experience major slowdowns or crashes with it set to 72. It is suggested that a DPI of 75 may be better, but I'm holding off on making it a default without more information.

## [1.0.2] - 2015-11-30
### Changed
- The default dpi is now 72. Previously the default would be whatever your `wkhtmltopdf` version specified as the default. This change [speeds up generation of documents that contain `border-radius` dramatically](https://github.com/wkhtmltopdf/wkhtmltopdf/issues/1510)

## [1.0.1] - 2015-11-19
### Changed
- Made minor RuboCop style tweaks.

### Added
- Added default [RuboCop](https://github.com/bbatsov/rubocop) config and run after test suite.

### Fixed
- Issue with `nil.basename` from asset helpers.

## [1.0.0] - 2015-11-03
### Changed
- Accepted that `WickedPDF` cannot guarantee backwards compatibility with older versions of `wkthmltopdf`, and decided to publish a new version with the MAJOR number incremented, signaling that this may have breaking changes for some people, but providing a path forward for progress. This release number also signals that this is a mature (and relatively stable) project, and should be deemed ready for production (since it has been used in production since ~2009, and downloaded over a *million* times on [RubyGems.org](https://rubygems.org/gems/wicked_pdf)).
- Stopped attempting to track with version number of `wkhtmltopdf` binary releases (`wkhtmltopdf` v9.x == `WickedPDF` v9.x)
- Adopted [Semantic Versioning](http://semver.org/) for release numbering
- Added a CHANGELOG (based on [keepachangelog.com](http://keepachangelog.com/))
- Misc code tweaks as suggested by [RuboCop](https://github.com/bbatsov/rubocop)

### Added
- Check version of `wkhtmltopdf` before deciding to pass arguments with or without dashes
- New arguments and options for the table of contents supported in newer versions of wkhtmltopf: `text_size_shrink`, `level_indentation`, `disable_dotted_lines`, `disable_toc_links`, `xsl_style_sheet`
- Merge in global options to `pdf_from_html_file` and `pdf_from_string`
- Add ability to generate pdf from a web resource: `pdf_from_url(url)`

### Removed
- Explicit dependency on [Rails](https://github.com/rails/rails), since parts of this library may be used without it.
- Comment out the `:exe_path` option in the generated initalizer by default (since many systems won't have `wkthmltopdf` installed in that specific location)

### Fixed
- Issues with `file://` paths on Windows-based systems
- Issues with parsed options/argument ordering on versions of `wkthmltopdf` > 0.9
- Issues with middleware headers when running Rails app mounted in a subdirectory
- Issues with options that have a `key: 'value'` syntax when passed to `wkthmltopdf`
- Issue with `:temp_path` option being deleted from original options hash
- Issue with header/footer `:content` being deleted after the first page
- Issues with options being modified during processing (including global config options)
- Issues with asset helpers recognizing assets specified without a protocol
- Issues with `url()` references and embedded `data:base64` assests in stylesheets rendered with `wicked_pdf_stylesheet_link_tag`
- Asset helpers no longer add a file extension if it already is specified with one

# Compare Releases
- [1.1.0...HEAD](https://github.com/mileszs/wicked_pdf/compare/1.1.0...HEAD)
- [1.0.6...1.1.0](https://github.com/mileszs/wicked_pdf/compare/1.0.6...1.1.0)
- [1.0.5...1.0.6](https://github.com/mileszs/wicked_pdf/compare/1.0.5...1.0.6)
- [1.0.4...1.0.5](https://github.com/mileszs/wicked_pdf/compare/1.0.4...1.0.5)
- [1.0.3...1.0.4](https://github.com/mileszs/wicked_pdf/compare/1.0.3...1.0.4)
- [1.0.2...1.0.3](https://github.com/mileszs/wicked_pdf/compare/1.0.2...1.0.3)
- [1.0.1...1.0.2](https://github.com/mileszs/wicked_pdf/compare/1.0.1...1.0.2)
- [1.0.0...1.0.1](https://github.com/mileszs/wicked_pdf/compare/1.0.0...1.0.1)
- [0.11.0...1.0.0](https://github.com/mileszs/wicked_pdf/compare/0.11.0...1.0.0)
- [0.10.2...0.11.0](https://github.com/mileszs/wicked_pdf/compare/0.10.2...0.11.0)
- [0.10.1...0.10.2](https://github.com/mileszs/wicked_pdf/compare/0.10.1...0.10.2)
- [0.10.0...0.10.1](https://github.com/mileszs/wicked_pdf/compare/0.10.0...0.10.1)
- [0.9.10...0.10.0](https://github.com/mileszs/wicked_pdf/compare/0.9.10...0.10.0)
