require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

class MarkabyTest < Test::Unit::TestCase
  include TestHelpers

  def teardown
    Markaby::Builder.restore_defaults!
  end

  def test_simple
    assert_equal "<hr/>", mab { hr }
    assert_equal "<hr/><br/>", mab {
                                 hr
                                 br
                               }
    assert_equal "<p>foo</p>", mab { p "foo" }
    assert_equal "<p>foo</p>", mab { p { "foo" } }
  end

  def test_escaping
    assert_equal "<h1>Apples &amp; Oranges</h1>", mab { h1 "Apples & Oranges" }
    assert_equal "<h1>Apples & Oranges</h1>", mab { h1 { "Apples & Oranges" } }
    assert_equal "<h1 class=\"fruits&amp;floots\">Apples</h1>", mab { h1 "Apples", class: "fruits&floots" }
  end

  def test_capture
    builder = Markaby::Builder.new
    assert builder.to_s.empty?
    assert_equal "<h1>TEST</h1>", builder.capture { h1 "TEST" }
    assert builder.to_s.empty?
    assert mab {
             capture { h1 "hello world" }
             nil
           }.empty?
    assert_equal mab { div { h1 "TEST" } }, mab { div { capture { h1 "TEST" } } }
  end

  def test_ivars
    html = "<div><h1>Steve</h1><div><h2>Gerald</h2></div><h3>Gerald</h3></div>"
    assert_equal html, mab {
                         div {
                           @name = "Steve"
                           h1 @name
                           div {
                             @name = "Gerald"
                             h2 @name
                           }
                           h3 @name
                         }
                       }
    assert_equal html, mab {
                         div {
                           @name = "Steve"
                           h1 @name
                           self << capture {
                             div {
                               @name = "Gerald"
                               h2 @name
                             }
                           }
                           h3 @name
                         }
                       }
    assert_equal html, mab(name: "Steve") {
                         div {
                           h1 @name
                           self << capture {
                             div {
                               @name = "Gerald"
                               h2 @name
                             }
                           }
                           h3 @name
                         }
                       }
  end

  def test_ivars_without_at_symbol
    assert_equal "<h1>Hello World</h1>", mab {
                                           @message = "Hello World"
                                           h1 message
                                         }
  end

  def test_helpers
    assert_equal %(squirrels), mab({}, MarkabyTestHelpers) { pluralize("squirrel") }
    assert_equal %(<a href="">edit</a>), mab({}, MarkabyTestHelpers) { link_to("edit") }
    assert mab({}, MarkabyTestHelpers) {
             link_to("edit")
             nil
           }.empty?
  end

  def test_uses_helper_instance_variable
    helper = Module.new do
      @some_ivar = :ivar_value
    end

    builder = Markaby::Builder.new({}, helper)
    assert_equal :ivar_value, builder.some_ivar
  end

  def test_builder_bang_methods
    assert_equal "<?xml version=\"1.0\" encoding=\"UTF-8\"?>", mab { instruct! }
  end

  def test_fragments
    assert_equal %(<div><h1>Monkeys</h1><h2>Giraffes <strong>Miniature</strong></h2><h3>Donkeys</h3></div>),
      mab {
        div {
          h1 "Monkeys"
          h2 { "Giraffes #{strong "Miniature"}" }
          h3 "Donkeys"
        }
      }

    assert_equal %(<div><h1>Monkeys</h1><h2>Giraffes <small>Miniature</small> and <strong>Large</strong></h2><h3>Donkeys</h3><h4>Parakeet <strong>Large</strong> as well...</h4></div>),
      mab {
        div {
          @a = small "Miniature"
          @b = strong "Large"
          h1 "Monkeys"
          h2 { "Giraffes #{@a} and #{@b}" }
          h3 "Donkeys"
          h4 { "Parakeet #{@b} as well..." }
        }
      }
  end

  def test_invalid_xhtml
    assert_exception(NoMethodError, "undefined method `dav'") { dav {} }
    assert_exception(Markaby::InvalidXhtmlError, "no attribute `styl' on div elements") { div(styl: "ok") {} }
    assert_exception(Markaby::InvalidXhtmlError, "no attribute `class' on tbody elements") { tbody.okay {} }
  end

  def test_full_doc_transitional
    doc = mab { xhtml_transitional { head { title "OKay" } } }
    assert doc =~ /^<\?xml version="1.0" encoding="UTF-8"\?>/
    assert doc.include?(%("-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">))
    assert doc.include?(%(<title>OKay</title>))
  end

  def test_full_doc_strict
    doc = mab { xhtml_strict { head { title "OKay" } } }
    assert doc =~ /^<\?xml version="1.0" encoding="UTF-8"\?>/
    assert doc.include?(%("-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">))
    assert doc.include?(%(<title>OKay</title>))
  end

  def test_full_doc_frameset
    doc = mab { xhtml_frameset { head { title "OKay" } } }
    assert doc =~ /^<\?xml version="1.0" encoding="UTF-8"\?>/
    assert doc.include?(%("-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">))
    assert doc.include?(%(<title>OKay</title>))
  end

  def test_root_attributes_can_be_changed
    doc = mab { xhtml_strict(lang: "fr") { head { title { "Salut!" } } } }
    assert doc.include?(%("-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">))
    assert doc.include?(%(<title>Salut!</title>))
    assert doc.include?(%( lang="fr"))
  end

  def version_file
    File.expand_path(File.dirname(__FILE__) + "/../../VERSION")
  end

  def test_markaby_should_have_correct_version
    assert_equal Markaby::VERSION, "0.9.0"
  end

  def test_duplicate_usage_of_same_id
    assert_raises Markaby::InvalidXhtmlError do
      mab do
        p.one!
        p.one!
      end
    end
  end

  # auto validation

  def test_tagging_with_invalid_tag_should_raise_error
    assert_raises Markaby::InvalidXhtmlError do
      mab do
        tag! :an_invalid_tag
      end
    end
  end

  def test_self_closing_html_tag_with_block_throws_errors
    assert_raises Markaby::InvalidXhtmlError do
      mab do
        html_tag :img do
        end
      end
    end
  end

  def test_local_assigning
    builder = Markaby::Builder.new(variable: :a_value)

    assert_equal :a_value, builder.variable
  end

  def test_local_assignment_with_strings
    builder = Markaby::Builder.new("variable" => :a_value)
    assert_equal :a_value, builder.variable
  end

  def test_local_assignment_prefers_symbols_to_strings
    builder = Markaby::Builder.new("variable" => "string_value", :variable => :symbol_value)
    assert_equal :symbol_value, builder.variable
  end

  def test_method_missing_should_call_tag_if_no_tagset_present
    Markaby::Builder.set(:tagset, nil)

    builder = Markaby::Builder.new
    builder.something.should == "<something/>"
  end
end
