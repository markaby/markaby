require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

class BuilderTest < Test::Unit::TestCase
  def setup
    Markaby::Builder.restore_defaults!
  end

  def teardown
    Markaby::Builder.restore_defaults!
  end

  def test_method_missing_is_private
    assert Markaby::Builder.private_instance_methods.include?("method_missing")
  end
  
  # setting options
  def test_should_be_able_to_restore_defaults_after_setting
    Markaby::Builder.set :indent, 2
    Markaby::Builder.restore_defaults!
    
    assert_equal 0, Markaby::Builder.get(:indent)
  end
  
  def test_should_be_able_set_global_options
    Markaby::Builder.set :indent, 2
    assert_equal 2, Markaby::Builder.get(:indent)
  end
  
  # internal clobbering by passed in assigns
  def test_internal_helpers_ivar_should_not_be_overwritten_by_assigns
    helper = Class.new do
      def some_method
        "a value"
      end
    end.new
    
    builder = Markaby::Builder.new({:helpers => nil}, helper)
    assert_equal "a value", builder.some_method
  end
end
