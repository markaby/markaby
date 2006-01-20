require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'markaby'))

class MarkabyTest < Test::Unit::TestCase
  
  def mab(string, assigns = {}, helpers = nil)
    Markaby::Template.new(string.to_s).render(assigns, helpers)
  end
  
  def setup
    @helpers = Module.new do
      def link_to(obj)
        %{<a href="">#{obj}</a>}
      end
      def pluralize(n, string)
        n == 1 ? string : string + "s"
      end
      module_function :link_to, :pluralize
    end
    @helpers_ohf = @helpers.dup
    @helpers_ohf.instance_variable_set("@output_helpers", false)
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
    assert_equal "<h1>Apples &amp; Oranges</h1>\n", mab("h1 'Apples & Oranges'")
    assert_equal "<h1>\nApples & Oranges</h1>\n", mab("h1 { 'Apples & Oranges' }")
  end

  def test_capture
    html = "<div>\n<h1>hello world</h1>\n</div>\n"
    assert_equal html, mab("div { h1 'hello world' }")
    assert_equal html, mab("div { capture { h1 'hello world' } }")
    assert mab("capture { h1 'hello world' }").empty?
  end

  def test_output_helpers
    assert_equal %{<a href="">edit</a>}, mab("link_to('edit')", {}, @helpers)
    assert mab("link_to('edit')", {}, @helpers_ohf).empty?
  end

end
