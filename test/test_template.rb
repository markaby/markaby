require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class TemplateTest < Test::Unit::TestCase
  def setup
    Markaby::Template.reset_builder_class!
  end
  
  def test_should_have_the_builder_class_as_builder_by_default
    assert_equal Markaby::Builder, Markaby::Template.builder_class
  end
  
  def test_should_have_the_builder_class_as_assignable
    Markaby::Template.builder_class = Object
    
    assert_equal Object, Markaby::Template.builder_class
  end
  
  def test_should_reset_builder_class
    Markaby::Template.builder_class = Object
    Markaby::Template.reset_builder_class!
    
    assert_equal Markaby::Builder, Markaby::Template.builder_class
  end
  
  def test_should_set_source
    builder = Markaby::Template.new("foo")
    
    assert_equal "foo", builder.source
  end
  
  def test_should_convert_source_to_string
    builder = Markaby::Template.new(:bar)
    
    assert_equal "bar", builder.source
  end
  
  # rendering
  def test_should_render_a_markaby_template_from_source
    template = Markaby::Template.new("h1.a_class do\np 'something'\nend")
    result = template.render
    
    assert_equal "<h1 class=\"a_class\"><p>something</p></h1>", result
  end
  
  class MockBuilder
    class << self
      def new
        @singleton ||= super
      end
      
      alias_method :singleton, :new
    end
    
    def initialize(*args)
      @instance_eval_args = []
    end
    
    attr_reader :instance_eval_args
    
    def instance_eval(*args)
      @instance_eval_args = args
      self
    end
    
    def to_s
      ""
    end
  end
  
  def test_should_render_with_path_when_one_is_set
    template = Markaby::Template.new("h1.a_class do\np 'something'\nend")
    result = template.render
    
    assert_equal "<h1 class=\"a_class\"><p>something</p></h1>", result
  end
  
  def test_should_use_instance_eval_with_string_only_when_no_path_is_set
    Markaby::Template.builder_class = MockBuilder
    
    template = Markaby::Template.new("code")
    template.render
    
    assert_equal MockBuilder.singleton.instance_eval_args, ["code"]
  end
  
  def test_should_use_instance_eval_with_string_and_path_when_path_is_set
    Markaby::Template.builder_class = MockBuilder
    
    template = Markaby::Template.new("code")
    template.path = "/a/template/path"
    template.render
    
    assert_equal MockBuilder.singleton.instance_eval_args, ["code", "/a/template/path"]
  end
end
