require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'markaby'))

module MarkabyTestHelpers
  def link_to(obj)
    %{<a href="">#{obj}</a>}
  end
  def pluralize(n, string)
    n == 1 ? string : string + "s"
  end
  module_function :link_to, :pluralize
end

class MarkabyTest < Test::Unit::TestCase

  def mab(*args, &block)
    Markaby::Builder.new(*args, &block).to_s
  end

  def assert_exception(exclass, exmsg, *mab_args, &block)
    begin
      mab(*mab_args, &block)
    rescue Exception => e
      assert_equal exclass, e.class
      assert_equal exmsg, e.message
    end
  end

  def test_simple
    assert_equal "<hr/>\n", mab { hr }
    assert_equal "<p>foo</p>\n", mab { p 'foo' }
    assert_equal "<p>\nfoo</p>\n", mab { p { 'foo' } }
  end
  
  def test_classes_and_ids
    assert_equal %{<div class="one"></div>\n}, mab { div.one '' }
    assert_equal %{<div class="one two"></div>\n}, mab { div.one.two '' }
    assert_equal %{<div id="three"></div>\n}, mab { div.three! '' }
  end
  
  def test_escaping
    assert_equal "<h1>Apples &amp; Oranges</h1>\n", mab { h1 'Apples & Oranges' }
    assert_equal "<h1>\nApples & Oranges</h1>\n", mab { h1 { 'Apples & Oranges' } }
    assert_equal "<h1 class=\"fruits&amp;floots\">Apples</h1>\n", mab { h1 'Apples', :class => 'fruits&floots' }
  end

  def test_capture
    builder = Markaby::Builder.new
    assert builder.to_s.empty?
    assert_equal "<h1>TEST</h1>\n", builder.capture { h1 'TEST' }
    assert builder.to_s.empty?
    assert mab { capture { h1 'hello world' } }.empty?
    assert_equal mab { div { h1 'TEST' } }, mab { div { capture { h1 'TEST' } } }
  end

  def test_ivars
    html = "<div>\n<h1>Steve</h1>\n<div>\n<h2>Gerald</h2>\n</div>\n<h3>Gerald</h3>\n</div>\n"
    assert_equal html, mab { div { @name = 'Steve'; h1 @name; div { @name = 'Gerald'; h2 @name }; h3 @name } }
    assert_equal html, mab { div { @name = 'Steve'; h1 @name; self << capture { div { @name = 'Gerald'; h2 @name } }; h3 @name } }
    assert_equal html, mab(:name => 'Steve') { div { h1 @name; self << capture { div { @name = 'Gerald'; h2 @name } }; h3 @name } }
  end

  def test_ivars_without_at_symbol
    assert_equal "<h1>Hello World</h1>\n", mab { @message = 'Hello World'; h1 message }
  end
  
  def test_output_helpers
    assert_equal %{<a href="">edit</a>}, mab({}, MarkabyTestHelpers) { link_to('edit') }
    assert mab({}, MarkabyTestHelpers) { @output_helpers = false; link_to('edit') }.empty?
  end

  def test_builder_bang_methods
    assert_equal "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", mab { instruct! }
  end

  def test_fragments
    assert_equal %{<div>\n<h1>Monkeys</h1>\n<h2>\nGiraffes <small>Miniature</small>\n and <strong>Large</strong>\n</h2>\n<h3>Donkeys</h3>\n<h4>\nParakeet <b>\n<i>Innocent IV</i>\n</b>\n in Classic Chartreuse</h4>\n</div>\n}, 
        mab { div { h1 "Monkeys"; h2 { "Giraffes #{small 'Miniature' } and #{strong 'Large'}" }; h3 "Donkeys"; h4 { "Parakeet #{b { i 'Innocent IV' }} in Classic Chartreuse" } } }
    assert_equal %{<div>\n<h1>Monkeys</h1>\n<h2>\nGiraffes <strong>Miniature</strong>\n</h2>\n<h3>Donkeys</h3>\n</div>\n}, 
        mab { div { h1 "Monkeys"; h2 { "Giraffes #{strong 'Miniature' }" }; h3 "Donkeys" } }
    assert_equal %{<div>\n<h1>Monkeys</h1>\n<h2>\nGiraffes <small>Miniature</small>\n and <strong>Large</strong>\n</h2>\n<h3>Donkeys</h3>\n<h4>\nParakeet <strong>Large</strong>\n as well...</h4>\n</div>\n}, 
        mab { div { @a = small 'Miniature'; @b = strong 'Large'; h1 "Monkeys"; h2 { "Giraffes #{@a} and #{@b}" }; h3 "Donkeys"; h4 { "Parakeet #{@b} as well..." } } }
  end

  def test_invalid_xhtml
    assert_exception(NoMethodError, "no such method `dav'") { dav {} }
    assert_exception(Markaby::InvalidXhtmlError, "no attribute `styl' on div elements") { div(:styl => 'ok') {} }
    assert_exception(Markaby::InvalidXhtmlError, "no attribute `class' on tbody elements") { tbody.okay {} }
  end

  def test_full_doc_transitional
    doc = %{<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"DTD/xhtml1-transitional.dtd\">
<html xml:lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">
<head>\n<meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\"/>\n<title>OKay</title>\n</head>\n</html>\n}
    assert_equal doc, mab { instruct!; html { head { title 'OKay' } } }
  end

  def test_full_doc_transitional
    doc = %{<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"DTD/xhtml1-strict.dtd\">
<html lang=\"en\" xml:lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\">
<head>\n<meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\"/>\n<title>OKay</title>\n</head>\n</html>\n}
    assert_equal doc, mab { xhtml_strict { head { title 'OKay' } } }
  end

end
