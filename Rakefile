require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/rdoctask'

task :default => [:test]

TEST_FILES = FileList['test/test*.rb']

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = TEST_FILES
  t.verbose = true
end

task :rcov do
  `rcov #{TEST_FILES}`
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.add(['README.rdoc', 'CHANGELOG.rdoc', 'lib/**/*.rb'])
end

begin
  require 'jeweler'
  
  Jeweler::Tasks.new do |gemspec|
    gemspec.name          = "Markaby"
    gemspec.summary       = "Markup as Ruby, write HTML in your native Ruby tongue"
    gemspec.description   = "Tim Fletcher and _why's ruby driven HTML templating system"
    gemspec.email         = "jrbarton@gmail.com"
    gemspec.homepage      = "http://joho.github.com/markaby/"
    gemspec.authors       = ["_why", "Tim Fletcher", "John Barton", "spox", "smtlaissezfaire"]
    gemspec.add_dependency 'builder', '>=2.0.0'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

desc "List any Markaby specific warnings"
task :warnings do
  `ruby -w test/test_markaby.rb 2>&1`.split(/\n/).each do |line|
    next unless line =~ /warning:/
    next if line =~ /builder-/
    puts line
  end
end

desc "Start a Markaby-aware IRB session"
task :irb do
  sh 'irb -I lib -r markaby -r markaby/kernel_method'
end

namespace :test do
  desc ''
  task :rails do
    Dir.chdir '../../../'
    sh 'rake test:plugins PLUGIN=markaby'
  end
end