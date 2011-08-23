require 'rake'
require 'rspec/core/rake_task'
require 'rake/testtask'
require 'rake/clean'

begin
  require 'hanna/rdoctask'

  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options << '--line-numbers'
    rdoc.rdoc_files.add(['README.rdoc', 'CHANGELOG.rdoc', 'lib/**/*.rb'])
  end
rescue LoadError
  puts "Could not load hanna-rdoc.  Please install with mislav-hanna package"
end

task :default => [:spec, :test]

Rake::TestTask.new(:test) do |t|
  t.pattern = 'spec/markaby/*_test.rb'
end

RSpec::Core::RakeTask.new(:spec)

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gemspec|
    gemspec.name          = "markaby"
    gemspec.summary       = "Markup as Ruby, write HTML in your native Ruby tongue"
    gemspec.description   = "Tim Fletcher and _why's ruby driven HTML templating system"
    gemspec.email         = "scott@railsnewbie.com"
    gemspec.homepage      = "http://markaby.github.com/markaby/"
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

namespace :gemspec do
  task :commit do
    sh "git add ."
    sh "git commit -m 'Update gemspec'"
  end
end

namespace :release do
  task :patch => [:spec, "version:bump:patch", :update_gemspec, :rerdoc, :tag_release, :build, :push_tags]

  task :update_gemspec => ["gemspec:generate", "gemspec:validate", "gemspec:commit"]
  task :tag_release do
    require File.dirname(__FILE__) + "/lib/markaby"
    version = "v#{Markaby::VERSION}"
    sh "git tag #{version}"
  end

  task :push_tags do
    sh "git push --tags"
  end
end

task :release => "release:patch"
