class WickedPdfGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "tempfile.rb", "config/initializers/tempfile.rb"
    end
  end
end
