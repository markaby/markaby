require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class BuilderTest < Test::Unit::TestCase
  def teardown
    Markaby::Builder.restore_defaults!
  end
  
  def test_method_missing_is_private
    assert Markaby::Builder.private_instance_methods.include?("method_missing")
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