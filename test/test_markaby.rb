require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'markaby'))

class MarkabyTest < Test::Unit::TestCase
  
  def mab(string, assigns = {}, helpers = nil)
    Markaby::Template.new(string.to_s).render(assigns, helpers)
  end
  
  def test_simple
    assert_equal "<hr/>\n", mab("hr")
    assert_equal "<p>foo</p>\n", mab("p 'foo'")
    assert_equal "<p>\nfoo</p>\n", mab("p { 'foo' }")
  end
  
  def test_classes_and_ids
    assert_equal %{<div class="one"></div>\n}, mab("div.one ''")
    assert_equal %{<div class="one two"></div>\n}, mab("div.one.two ''")
    assert_equal %{<div id="three"></div>\n}, mab("div.three! ''")
  end
  
  def test_escaping
    assert_equal %{<h1>Apples &amp; Oranges</h1>\n}, mab("h1 'Apples & Oranges'")
    assert_equal %{<h1>\nApples & Oranges</h1>\n}, mab("h1 { 'Apples & Oranges' }")
  end
  
end