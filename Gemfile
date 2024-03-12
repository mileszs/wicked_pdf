source 'https://rubygems.org'

gemspec
# use ENV vars, with default value as fallback for local setup
ruby(ENV['RUBY_VERSION'] || '3.2.2') unless ENV['RUBY_VERSION'] == 'truffleruby'

gem 'bootsnap' # required to run `rake test`
gem 'rails', "~> #{ENV['RAILS_VERSION'] || '7.0'}.0"
gem 'rdoc'
gem 'sprockets', "~> #{ENV['SPROCKETS_VERSION'] || '3.0'}" # v4 strips newlines from assets causing tests to fail
gem 'sprockets-rails'
gem 'sqlite3', '~> 1.4'
gem 'webpacker'
