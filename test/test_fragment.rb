require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class FragmentTest < Test::Unit::TestCase
  def test_method_missing_is_private
    assert Markaby::Fragment.private_instance_methods.include?("method_missing")
  end
end