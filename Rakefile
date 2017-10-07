require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rails/version'
require 'bundler/gem_tasks'

desc 'Default: run unit tests.'
task :default => [:setup_and_run_tests, :rubocop]

desc 'Test the wicked_pdf plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Run RuboCop'
task :rubocop do
  next unless RUBY_VERSION >= '2.0.0'
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
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
  command = Rails::VERSION::MAJOR == 2 ? '' : 'new'
  system("rails #{command} test/dummy")
  system('touch test/dummy/db/schema.rb')
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
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
