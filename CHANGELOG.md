# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [master] - Unpublished
### Changed
- The default dpi is now 72. Previously the default would be whatever your `wkhtmltopdf` version specified as the default. This change [speeds up generation of documents that contain `border-radius` dramatically](https://github.com/wkhtmltopdf/wkhtmltopdf/issues/1510)

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
- [1.0.0...Unreleased](https://github.com/mileszs/wicked_pdf/compare/f0b49fa...HEAD)
- [1.0.0...1.0.1](https://github.com/mileszs/wicked_pdf/compare/24303d0...f0b49fa)
- [0.11.0...1.0.0](https://github.com/mileszs/wicked_pdf/compare/968ae69...24303d0)
- [0.10.2...0.11.0](https://github.com/mileszs/wicked_pdf/compare/076f043...968ae69)
- [0.10.1...0.10.2](https://github.com/mileszs/wicked_pdf/compare/a920bc9...076f043)
- [0.10.0...0.10.1](https://github.com/mileszs/wicked_pdf/compare/df67c30...a920bc9)
- [0.9.10...0.10.0](https://github.com/mileszs/wicked_pdf/compare/9daecee...df67c30)
