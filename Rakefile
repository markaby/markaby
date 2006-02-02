require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'tools/rakehelp'
require 'fileutils'
include FileUtils

setup_tests
setup_rdoc ['README', 'CHANGELOG', 'lib/**/*.rb']

summary = "Markup as Ruby, write HTML in your native Ruby tongue"
test_file = "test/test_markaby.rb"
setup_gem("markaby", "0.3",  "Tim Fletcher and _why", summary, ['builder'], test_file)
