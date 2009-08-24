require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class CssProxyTest < Test::Unit::TestCase
  def test_method_missing_is_private
    assert Markaby::CssProxy.private_instance_methods.include?("method_missing")
  end
end