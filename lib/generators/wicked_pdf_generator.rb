if defined?(Rails) && Rails::VERSION::MAJOR != 2

  # Rails3 generator invoked with 'rails generate wicked_pdf'
  class WickedPdfGenerator < Rails::Generators::Base
    source_root(File.expand_path(File.dirname(__FILE__) + "/../../generators/wicked_pdf/templates"))
    def copy_initializer
      copy_file 'wicked_pdf.rb', 'config/initializers/wicked_pdf.rb'
    end
  end

end