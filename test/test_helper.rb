# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb', __FILE__)

require 'test/unit'
require 'mocha'

if Rails::VERSION::MAJOR == 2
  require 'test_help'
else
  require 'rails/test_help'
  require 'mocha/test_unit'
end

require 'wicked_pdf'

Rails.backtrace_cleaner.remove_silencers!

if (assets_dir = Rails.root.join('app/assets')) && File.directory?(assets_dir)
  destination = assets_dir.join('stylesheets/wicked.css')
  source = File.read('test/fixtures/wicked.css')
  File.open(destination, 'w') { |f| f.write(source) }
end