# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

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
