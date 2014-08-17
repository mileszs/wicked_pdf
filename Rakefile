require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rails/version'
require 'bundler/gem_tasks'

desc 'Default: run unit tests.'
task :default => :setup_and_run_tests

desc 'Test the wicked_pdf plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Setup and run all tests'
task :setup_and_run_tests do
  unless File.exist?('test/dummy/config/environment.rb')
    Rake::Task[:dummy_generate].invoke
  end
  Rake::Task[:test].invoke
end

desc 'Generate dummy application for test cases'
task :dummy_generate do
  Rake::Task[:dummy_remove].invoke
  puts 'Creating dummy application to run tests'

  prefix = ''
  if Rails::VERSION::MAJOR != 2
    prefix = 'new '
  end

  system("rails #{prefix}test/dummy")
  FileUtils.rm_r Dir.glob('test/dummy/test/*')
end

desc 'Remove dummy application'
task :dummy_remove do
  FileUtils.rm_r Dir.glob('test/dummy/*')
end

desc 'Generate documentation for the wicked_pdf plugin.'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'WickedPdf'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
