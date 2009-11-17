class WickedPdfGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "tempfile.rb", "config/initializers/tempfile.rb"
      m.file "wicked_pdf.rb", "config/initializers/wicked_pdf.rb"
    end
  end
end
