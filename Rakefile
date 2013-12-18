require 'rake'
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'rake/clean'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

Bundler::GemHelper.install_tasks

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

# namespace :release do
#   task :patch => [:spec, "version:bump:patch", :update_gemspec, :rerdoc, :tag_release, :build, :push_tags]
#
#   task :update_gemspec => ["gemspec:generate", "gemspec:validate", "gemspec:commit"]
#   task :tag_release do
#     require File.dirname(__FILE__) + "/lib/markaby"
#     version = "v#{Markaby::VERSION}"
#     sh "git tag #{version}"
#   end
#
#   task :push_tags do
#     sh "git push --tags"
#   end
# end
#
# task :release => "release:patch"
