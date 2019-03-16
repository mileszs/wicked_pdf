# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

WickedPdf.config = {
  # Path to the wkhtmltopdf executable.
  # WickedPDF will automatically find the correct binary,
  # based on presence of one of the wkhtmltopdf-binary family
  # of gems, known locations in the filesystem, or by querying
  # the OS. What you configure here overrules everything.
  #
  # exe_path: '/opt/wkhtmltopdf/bin/wkhtmltopdf'

  # Layout file to be used for all PDFs
  # (but can be overridden in `render :pdf` calls)
  #
  # layout: 'pdf.html',
}
