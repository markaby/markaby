require "rspec"

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))

require "markaby"
require "markaby/kernel_method"
require "markaby/rails"
require "test/unit"

# need to set this to true otherwise Test::Unit goes berserk + tries to run
# see https://jonleighton.name/2012/stop-test-unit-autorun/
Test::Unit.run = true

module MarkabyTestHelpers
  def link_to(obj)
    %(<a href="">#{obj}</a>)
  end

  def pluralize(string)
    string + "s"
  end

  module_function :link_to, :pluralize
end

module TestHelpers
  def assert_exception(exclass, exmsg, *mab_args, &block)
    mab(*mab_args, &block)
  rescue => e
    assert_equal exclass, e.class
    assert_match(/#{exmsg}/, e.message)
  end
end

RSpec.configure do |c|
  c.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }
end
