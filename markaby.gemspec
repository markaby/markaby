# This gemspec is not recommended for install and is here
# as a stub to remind me that it's an option someday...
require 'rubygems'
spec = Gem::Specification.new do |s|
  s.name = 'markaby'
  s.version = "0.2"
  s.platform = Gem::Platform::RUBY
  s.summary = "Markup as Ruby, write HTML in your native Ruby tongue"
  s.add_dependency('builder')
  s.files = ['test/**/*', 'lib/**/*', 'bin/**/*'].collect do |dirglob|
                Dir.glob(dirglob)
            end.flatten.delete_if {|item| item.include?("CVS")}
  s.require_path = 'lib'
  s.autorequire = 'markaby'
  s.author = "why the lucky stiff"
  s.email = "why@ruby-lang.org"
  s.rubyforge_project = "hobix"
  s.homepage = "http://whytheluckystiff.net/markaby/"
end
if $0==__FILE__
  Gem::Builder.new(spec).build
end
