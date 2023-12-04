require "rake"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/clean"

RSpec::Core::RakeTask.new(:spec)
task default: :spec

Bundler::GemHelper.install_tasks

desc "List any Markaby specific warnings"
task :warnings do
  `ruby -w test/test_markaby.rb 2>&1`.split("\n").each do |line|
    next unless /warning:/.match?(line)
    next if /builder-/.match?(line)
    puts line
  end
end

desc "Start a Markaby-aware IRB session"
task :irb do
  sh "irb -I lib -r markaby -r markaby/kernel_method"
end

namespace :gemspec do
  task :commit do
    sh "git add ."
    sh "git commit -m 'Update gemspec'"
  end
end

namespace :release do
  # make sure to bump version + update changelogs in lib/markaby/version.rb before running
  task :patch => [:spec, :update_gemspec, :tag_release, :build, :push_tags]

  task :update_gemspec => ["gemspec:commit"]

  task :tag_release do
    require File.dirname(__FILE__) + "/lib/markaby"
    version = "v#{Markaby::VERSION}"
    sh "git tag #{version}"
  end

  task :push_tags do
    sh "git push --tags"
  end

  task :push_gem do
    sh "gem push pkg/markaby-#{Markaby::VERSION}.gem"
  end
end

task :release => "release:patch"
