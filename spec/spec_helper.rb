require 'rubygems'
require 'test/unit'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'markaby'
require 'markaby/kernel_method'

module MarkabyTestHelpers
  def link_to(obj)
    %{<a href="">#{obj}</a>}
  end
  def pluralize(string)
    string + "s"
  end
  module_function :link_to, :pluralize
end

module TestHelpers
  def assert_exception(exclass, exmsg, *mab_args, &block)
    begin
      mab(*mab_args, &block)
    rescue Exception => e
      assert_equal exclass, e.class
      assert_match /#{exmsg}/, e.message
    end
  end
end

module Test
  module Unit
    class TestCase
      include TestHelpers
    end
  end
end