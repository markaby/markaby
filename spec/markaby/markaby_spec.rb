require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Markaby do
  it "can assign helpers after instantiation" do
    helper = double 'helper', :foo => :bar

    builder = Markaby::Builder.new
    builder.helper = helper
    builder.foo.should == :bar
  end

  it "should be able to set a local" do
    builder = Markaby::Builder.new
    builder.locals = { :foo => "bar" }
    builder.foo.should == "bar"
  end

  it "should be able to set a different local value" do
    builder = Markaby::Builder.new
    builder.locals = { :foo => "baz" }
    builder.foo.should == "baz"
  end

  it "should assign the correct key" do
    builder = Markaby::Builder.new
    builder.locals = { :key => :value }
    builder.key.should == :value
  end

  it "should be able to assign multiple locals" do
    builder = Markaby::Builder.new

    builder.locals = { :one => "two", :three => "four" }

    builder.one.should == "two"
    builder.three.should == "four"
  end

  def test_builder_bang_methods
    assert_equal "<?xml version=\"1.0\" encoding=\"UTF-8\"?>", mab { instruct! }
  end

  it "should be able to produce the correct html from a fragment" do
    str = ""
    str += "<div>"
    str += "<h1>Monkeys</h1>"
    str += "<h2>Giraffes <small>Miniature</small> and <strong>Large</strong></h2>"
    str += "<h3>Donkeys</h3>"
    str += "<h4>Parakeet <b><i>Innocent IV</i></b> in Classic Chartreuse</h4>"
    str += "</div>"

    generated = mab {
      div {
        h1 "Monkeys"
        h2 {
          "Giraffes #{small('Miniature')} and #{strong 'Large'}".html_safe
        }
        h3 "Donkeys"
        h4 { "Parakeet #{b { i 'Innocent IV' }} in Classic Chartreuse".html_safe }
      }
    }

    generated.should == str
  end

  def test_fragments
    assert_equal %{<div><h1>Monkeys</h1><h2>Giraffes <strong>Miniature</strong></h2><h3>Donkeys</h3></div>},
        mab { div { h1 "Monkeys"; h2 { "Giraffes #{strong 'Miniature' }" }; h3 "Donkeys" } }

    assert_equal %{<div><h1>Monkeys</h1><h2>Giraffes <small>Miniature</small> and <strong>Large</strong></h2><h3>Donkeys</h3><h4>Parakeet <strong>Large</strong> as well...</h4></div>},
        mab { div { @a = small 'Miniature'; @b = strong 'Large'; h1 "Monkeys"; h2 { "Giraffes #{@a} and #{@b}" }; h3 "Donkeys"; h4 { "Parakeet #{@b} as well..." } } }
  end

  def test_invalid_xhtml
    assert_exception(NoMethodError, "undefined method `dav'") { dav {} }
    assert_exception(Markaby::InvalidXhtmlError, "no attribute `styl' on div elements") { div(:styl => 'ok') {} }
    assert_exception(Markaby::InvalidXhtmlError, "no attribute `class' on tbody elements") { tbody.okay {} }
  end

  def test_full_doc_transitional
    doc = mab { xhtml_transitional { head { title 'OKay' } } }
    assert doc =~ /^<\?xml version="1.0" encoding="UTF-8"\?>/
    assert doc.include?(%{"-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">})
    assert doc.include?(%{<title>OKay</title>})
  end

  def test_full_doc_strict
    doc = mab { xhtml_strict { head { title 'OKay' } } }
    assert doc =~ /^<\?xml version="1.0" encoding="UTF-8"\?>/
    assert doc.include?(%{"-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">})
    assert doc.include?(%{<title>OKay</title>})
  end

  def test_full_doc_frameset
    doc = mab { xhtml_frameset { head { title 'OKay' } } }
    assert doc =~ /^<\?xml version="1.0" encoding="UTF-8"\?>/
    assert doc.include?(%{"-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">})
    assert doc.include?(%{<title>OKay</title>})
  end

  def test_root_attributes_can_be_changed
    doc = mab { xhtml_strict(:lang => 'fr') { head { title { 'Salut!' } } } }
    assert doc.include?(%{"-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">})
    assert doc.include?(%{<title>Salut!</title>})
    assert doc.include?(%{ lang="fr"})
  end

  def version_file
    File.expand_path(File.dirname(__FILE__) + "/../../VERSION")
  end

  def test_markaby_should_have_correct_version
    assert_equal Markaby::VERSION, File.read(version_file).strip
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
    builder = Markaby::Builder.new(:variable => :a_value)

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

  it "should copy instance variables from a helper object" do
    klass = Class.new do
      def initialize
        @hello = "hello there"
      end
    end

    builder = Markaby::Builder.new({}, klass.new)
    builder.capture { @hello }.should == "hello there"
  end

  describe Markaby::InvalidXhtmlError do
    it "should inherit from StandardError" do
      Markaby::InvalidXhtmlError.superclass.should == StandardError
    end
  end
end

