# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [master branch] - Unreleased
### Breaking Changes
- None
### New Features
- None
### Fixes
- None

## [2.1.0] - 2020-06-14
### Fixes
- [Document no_stop_slow_scripts in README](https://github.com/mileszs/wicked_pdf/pull/905)
- [Document how to use locals in README](https://github.com/mileszs/wicked_pdf/pull/915)

### New Features
- [Improved support for Webpacker assets with `wicked_pdf_asset_pack_path`](https://github.com/mileszs/wicked_pdf/pull/896)
- [Support enabling/disabling local file access compatible with wkhtmltopdf 0.12.6](https://github.com/mileszs/wicked_pdf/pull/920)
- [Add option `use_xvfb` to emulate an X server](https://github.com/mileszs/wicked_pdf/pull/909)

## [2.0.2] - 2020-03-17
### Fixes
- [Force UTF-8 encoding in assets helper](https://github.com/mileszs/wicked_pdf/pull/894)

## [2.0.1] - 2020-02-22
### Fixes
- [Replace open-uri with more secure Net:HTTP.get](https://github.com/mileszs/wicked_pdf/pull/864)

## [2.0.0] - 2020-02-22
### Breaking changes
- [Remove support for older Ruby and Rails versions](https://github.com/mileszs/wicked_pdf/pull/854) - This project no longer supports Ruby < 2.2 and Rails < 4. It may work for you, but we are no longer worrying about breaking backwards compatibility for versions older than these. If you are on an affected version, you can continue to use the 1.x releases. Patches to fix broken behavior on old versions may not be accepted unless they are highly decoupled from the rest of the code base.

### New Features
- [Add Rubygems metadata hash to gemspec](https://github.com/mileszs/wicked_pdf/pull/856)
- [Add support for Rails 6](https://github.com/mileszs/wicked_pdf/pull/869)

### Fixes
- [Fix Webpacker helpers in production environment](https://github.com/mileszs/wicked_pdf/pull/837)
- [Fix unit tests](https://github.com/mileszs/wicked_pdf/pull/852)

## [1.4.0] - 2019-05-23
### New Features
- [Add support for `log_level` and `quiet` options](https://github.com/mileszs/wicked_pdf/pull/834)

## [1.3.0] - 2019-05-20
### New Features
- [Add support for Webpacker provided bundles](https://github.com/mileszs/wicked_pdf/pull/739)

## [1.2.2] - 2019-04-13
### Fixes
- [Fix issue loading Pty on Windows](https://github.com/mileszs/wicked_pdf/pull/820)
- [Fix conflict with remotipart causing SystemStackError](https://github.com/mileszs/wicked_pdf/pull/821)

## [1.2.1] - 2019-03-16
### Fixes
- [Fix `SystemStackError` in some setups](https://github.com/mileszs/wicked_pdf/pull/813)

## [1.2.0] - 2019-03-16
### New Features
- [Add `raise_on_all_errors: true` option to raise on any error that prints to STDOUT during PDF generation](https://github.com/mileszs/wicked_pdf/pull/751)
- [Add ability to use the `assigns` option to `render` to assign instance variables to a PDF template](https://github.com/mileszs/wicked_pdf/pull/801)
- [Add ability to track console progress](https://github.com/mileszs/wicked_pdf/pull/804) with `progress: -> (output) { puts output }`. This is useful to add reporting hooks to show your frontend what page number is being generated.

### Fixes
- [Fix conflict with other gems that hook into `render`](https://github.com/mileszs/wicked_pdf/pull/574) and avoid using `alias_method_chain` where possible
- [Fix issue using the shell to locate `wkhtmltopdf` in a Bundler environment](https://github.com/mileszs/wicked_pdf/pull/728)
- [Fix `wkhtmltopdf` path detection when HOME environment variable is unset](https://github.com/mileszs/wicked_pdf/pull/568)
- [Fix error when the `Rails` constant is defined but not actually using Rails](https://github.com/mileszs/wicked_pdf/pull/613)
- [Fix compatibility issue with Sprockets 4](https://github.com/mileszs/wicked_pdf/pull/615)
- [Fix compatibility issue with `Mime::JS` in Rails 5.1+](https://github.com/mileszs/wicked_pdf/pull/627)
- [Fix deprecation warning by using `after_action` instead of `after_filter` when available](https://github.com/mileszs/wicked_pdf/pull/663)
- [Provide Rails `base_path` to `find_asset` calls for Sprockets file lookup](https://github.com/mileszs/wicked_pdf/pull/688)
- Logger changes:
    - [Use `Rails.logger.debug` instead of `p`](https://github.com/mileszs/wicked_pdf/pull/575)
    - [Change logger message to prepend `[wicked_pdf]` instead of nonstandard `****************WICKED****************`](https://github.com/mileszs/wicked_pdf/pull/589)
- Documentation changes:
    - [Update link to wkhtmltopdf homepage](https://github.com/mileszs/wicked_pdf/pull/582)
    - [Update link to `wkhtmltopdf_binary_gem`](https://github.com/mileszs/wicked_pdf/commit/59e6c5fca3985f2fa2f345089596250df5da2682)
    - [Update documentation for usage with the Asset Pipeline](https://github.com/mileszs/wicked_pdf/commit/690d00157706699a71b7dcd71834759f4d84702f)
    - [Document `default_protocol` option](https://github.com/mileszs/wicked_pdf/pull/585)
    - [Document `image` and `no_image` options](https://github.com/mileszs/wicked_pdf/pull/689)
    - [Document issue with DPI/scaling on various platforms](https://github.com/mileszs/wicked_pdf/pull/715)
    - [Document creating and attaching a PDF in a mailer](https://github.com/mileszs/wicked_pdf/pull/746)
    - [Document dependency on `wkhtmltopdf` with RubyGems](https://github.com/mileszs/wicked_pdf/pull/656)
    - [Add example using WickedPDF with Rails in an API-only configuration](https://github.com/mileszs/wicked_pdf/pull/796)
    - [Add example for rending a template as a header/footer](https://github.com/mileszs/wicked_pdf/pull/603)
    - [Add GitHub issue template](https://github.com/mileszs/wicked_pdf/pull/805)
    - [Add CodeClimate Badge](https://github.com/mileszs/wicked_pdf/pull/646)
- RuboCop cleanup
- Updates to Travis CI pipeline to support newer versions of Ruby & Rails

## [1.1.0] - 2016-08-30
### New Features
- Support Rails 5.x and Sprockets 3.x
- Support `window_status: 'somestring'` option, to instruct wkhtmltopdf to wait until the browser `window.status` is equal to the supplied string. This can be useful to force rendering to wait [as explained quite well here](https://spin.atomicobject.com/2015/08/29/ember-app-done-loading/)
- Support `no_stop_slow_scripts: true` to let slow running scripts delay rendering
- [Changes to asset finding to support Rails 5](https://github.com/mileszs/wicked_pdf/pull/561)

### Fixes
- [Improved error handling](https://github.com/mileszs/wicked_pdf/pull/543)
- [Namespace helper classes under WickedPdf namespace](https://github.com/mileszs/wicked_pdf/pull/538)

## [1.0.6] - 2016-04-04
### Fixes
- Revert shell escaping of options. The fix was causing more issues than it solved (like "[page] of [topage]" being escaped, and thus not parsed by `wkhtmltopdf`). See #514 for details.

## [1.0.5] - 2016-03-28
### Fixes
- Numerous RuboCop style violation fixes, spelling errors, and test-setup issues from [indyrb.org](http://indyrb.org/) hack night. Thank you all for your contributions!
- Shellescape options. A stray quote in `header` or `footer` would cause PDF to fail to generate, and this should close down many potential attack vectors if you allow user-supplied values to be passed into `wicked_pdf` render options.

## [1.0.4] - 2016-01-26
### Fixes
- Check that logger responds to info before calling it. It was possible to have a `logger` method defined as a controller helper that would override `Rails.logger`.
- [Issue with Sprockets 3.0](https://github.com/mileszs/wicked_pdf/issues/476) where an asset referenced in a stylesheet not existing would raise an exception `read_asset` on nil.

## [1.0.3] - 2015-12-02
### Fixes
- Revert default DPI. Some installs of `wkhtmltopdf` would experience major slowdowns or crashes with it set to 72. It is suggested that a DPI of 75 may be better, but I'm holding off on making it a default without more information.

## [1.0.2] - 2015-11-30
### Fixes
- The default dpi is now 72. Previously the default would be whatever your `wkhtmltopdf` version specified as the default. This change [speeds up generation of documents that contain `border-radius` dramatically](https://github.com/wkhtmltopdf/wkhtmltopdf/issues/1510)

## [1.0.1] - 2015-11-19
### Fixes
- Made minor RuboCop style tweaks.
- Added default [RuboCop](https://github.com/bbatsov/rubocop) config and run after test suite.
- Issue with `nil.basename` from asset helpers.

## [1.0.0] - 2015-11-03
### Breaking Changes
- Accepted that `WickedPDF` cannot guarantee backwards compatibility with older versions of `wkthmltopdf`, and decided to publish a new version with the MAJOR number incremented, signaling that this may have breaking changes for some people, but providing a path forward for progress. This release number also signals that this is a mature (and relatively stable) project, and should be deemed ready for production (since it has been used in production since ~2009, and downloaded over a *million* times on [RubyGems.org](https://rubygems.org/gems/wicked_pdf)).
- Stopped attempting to track with version number of `wkhtmltopdf` binary releases (`wkhtmltopdf` v9.x == `WickedPDF` v9.x)
- Adopted [Semantic Versioning](http://semver.org/) for release numbering
- Added a CHANGELOG (based on [keepachangelog.com](http://keepachangelog.com/))
- Misc code tweaks as suggested by [RuboCop](https://github.com/bbatsov/rubocop)

### New Features
- Check version of `wkhtmltopdf` before deciding to pass arguments with or without dashes
- New arguments and options for the table of contents supported in newer versions of wkhtmltopdf: `text_size_shrink`, `level_indentation`, `disable_dotted_lines`, `disable_toc_links`, `xsl_style_sheet`
- Merge in global options to `pdf_from_html_file` and `pdf_from_string`
- Add ability to generate pdf from a web resource: `pdf_from_url(url)`
- Removed explicit dependency on [Rails](https://github.com/rails/rails), since parts of this library may be used without it.

### Fixes
- Comment out the `:exe_path` option in the generated initializer by default (since many systems won't have `wkthmltopdf` installed in that specific location)
- Issues with `file://` paths on Windows-based systems
- Issues with parsed options/argument ordering on versions of `wkthmltopdf` > 0.9
- Issues with middleware headers when running Rails app mounted in a subdirectory
- Issues with options that have a `key: 'value'` syntax when passed to `wkthmltopdf`
- Issue with `:temp_path` option being deleted from original options hash
- Issue with header/footer `:content` being deleted after the first page
- Issues with options being modified during processing (including global config options)
- Issues with asset helpers recognizing assets specified without a protocol
- Issues with `url()` references and embedded `data:base64` assets in stylesheets rendered with `wicked_pdf_stylesheet_link_tag`
- Asset helpers no longer add a file extension if it already is specified with one

# Compare Releases
- [2.1.0...HEAD (unreleased changes)](https://github.com/mileszs/wicked_pdf/compare/2.1.0...HEAD)
- [2.0.2...2.1.0](https://github.com/mileszs/wicked_pdf/compare/2.0.2...2.1.0)
- [2.0.0...2.0.2](https://github.com/mileszs/wicked_pdf/compare/2.0.0...2.0.2)
- [1.4.0...2.0.0](https://github.com/mileszs/wicked_pdf/compare/1.4.0...2.0.0)
- [1.3.0...1.4.0](https://github.com/mileszs/wicked_pdf/compare/1.3.0...1.4.0)
- [1.2.0...1.3.0](https://github.com/mileszs/wicked_pdf/compare/1.2.0...1.3.0)
- [1.1.0...1.2.0](https://github.com/mileszs/wicked_pdf/compare/1.1.0...1.2.0)
- [1.0.0...1.1.0](https://github.com/mileszs/wicked_pdf/compare/1.0.0...1.0.0)
- [0.11.0...1.0.0](https://github.com/mileszs/wicked_pdf/compare/0.11.0...1.0.0)
