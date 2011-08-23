require 'test/unit'
require 'test/unit/autorunner'
require 'rspec'

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'markaby'
require 'markaby/kernel_method'
require 'markaby/rails'

require 'erb'
require 'markaby/rails/spec_helper'

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
      def self.it(name, &blk)
        define_method("test_#{name}", &blk)
      end
    end
  end
end
