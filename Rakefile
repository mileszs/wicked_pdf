require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rails/version'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the wicked_pdf plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc "Generate dummy application for test cases"
task :dummy_generate do
	# recursively remove test/dummy directory entity
	FileUtils.rm_r Dir.glob('test/dummy/*')

	prefix = ''
	if Rails::VERSION::MAJOR != 2
		prefix = 'new '
	end

	system("rails #{prefix}test/dummy")
	
	FileUtils.rm_r Dir.glob('test/dummy/test/*')
end

desc 'Generate documentation for the wicked_pdf plugin.'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'WickedPdf'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
