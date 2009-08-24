require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class CssProxyTest < Test::Unit::TestCase
  def test_method_missing_is_private
    assert Markaby::CssProxy.private_instance_methods.include?("method_missing")
  end

  def mock_builder
    mock_builder = Class.new do
      def tag!(*args); end
    end.new
  end

  def test_responds_to_everything
    proxy = Markaby::CssProxy.new(mock_builder, 'stream', :sym)

    assert proxy.respond_to?(:any_method)
    assert proxy.respond_to?(:foobarbazasdfasdfadfs)
  end

  def test_does_not_respond_to_method_missing
    proxy = Markaby::CssProxy.new(mock_builder, 'stream', :sym)

    assert !proxy.respond_to?(:method_missing)
  end

  def test_does_respond_to_private_instance_methods_with_private_flag_set_to_true
    proxy = Markaby::CssProxy.new(mock_builder, 'stream', :sym)

    assert proxy.respond_to?(:method_missing, true)
  end

  def test_does_not_respond_to_private_instance_methods_with_private_flag_set_to_false
    proxy = Markaby::CssProxy.new(mock_builder, 'stream', :sym)

    assert !proxy.respond_to?(:method_missing, false)
  end

  def test_respond_to_should_always_return_boolean
    proxy = Markaby::CssProxy.new(mock_builder, 'stream', :sym)

    assert_equal proxy.respond_to?(:method_missing, :a_value), true
  end
end