require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "redfinger #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end