require File.expand_path('../rails/spec_helper', __FILE__)

if RUNNING_RAILS
  class NonSpecificTestController < ActionController::Base
    VIEW_PATH = File.expand_path(File.join(File.dirname(__FILE__), 'rails', 'views'))

    around_filter :catch_exceptions

    attr_reader :last_exception

    def catch_exceptions
      yield
    rescue Exception => @last_exception
      raise @last_exception
    end
  end

  if Markaby::Rails.deprecated_rails_version?
    class ActionController::TestCase < Test::Unit::TestCase; end

    class TestController < NonSpecificTestController
      self.template_root = VIEW_PATH
    end
  else
    class TestController < NonSpecificTestController
      append_view_path(VIEW_PATH)
    end
  end

  class MarkabyController < TestController
    def renders_nothing
      render :text => ""
    end

    def renders_erb_with_explicit_template
      render :template => "markaby/renders_erb"
    end

    def render_inline_content
      mab_content = mab do
        ul do
          li "Scott"
        end
      end

      render :inline => mab_content
    end

    def render_explicit_but_empty_markaby_layout
      render :template => "markaby/render_explicit_but_empty_markaby_layout.mab"
    end

    def no_values_passed
      render :template => "markaby/no_values_passed"
    end

    def correct_template_values
      render :template => "markaby/correct_template_values"
    end

    def render_erb_without_explicit_render_call
    end

    def render_mab_without_explicit_render_call
    end

    def render_with_ivar
      @user = "smtlaissezfaire"
      render :template => "markaby/render_with_ivar"
    end

    def access_to_helpers
      render :template => "markaby/access_to_helpers"
    end

    def renders_partial
      render :template => "markaby/partial_parent"
    end

    def renders_partial_with_locals
      render :template => "markaby/partial_parent_with_locals"
    end

    def render_which_raises_error
      render :template => "markaby/broken"
    end

    def renders_form_for
      @obj = Object.new
      render :template => "markaby/form_for"
    end

    def render_form_for_with_fields
      @obj = Object.new
      def @obj.foo
        "bar"
      end

      render :template => "markaby/form_for_with_fields"
    end

    def render_form_for_with_multiple_fields
      @obj = Object.new

      def @obj.foo
        "bar"
      end

      def @obj.baz
        "quxx"
      end

      render :template => "markaby/form_for_with_multiple_fields"
    end

    def routes
    end

    def commented_out_template
    end

    def render_with_yielding
      render :layout   => "layout.mab",
             :template => "markaby/yielding"
    end

    def render_with_yielding_where_template_has_two_elements
      render :layout   => "layout.mab",
             :template => "markaby/yielding_two"
    end

    def render_with_yielding_content_for_block
      render :layout   => "layout.mab",
             :template => "markaby/yielding_with_content_for"
    end

    def render_content_for_with_block_helper
      @obj = Object.new
      def @obj.foo
        "bar"
      end

      render :layout   => "layout.mab",
             :template => "markaby/yielding_content_for_with_block_helper"
    end

    def renders_content_for_with_form_for_without_double_render
      @obj = Object.new
      def @obj.foo
        "bar"
      end

      render :layout   => "layout.mab",
             :template => "markaby/double_output"
    end

    def renders_form_for_with_erb_body
      @obj = Object.new

      def @obj.foo
        "bar"
      end
    end
  end

  class MarkabyOnRailsTest < ActionController::TestCase
    def setup
      Markaby::Builder.restore_defaults!

      @request = ActionController::TestRequest.new
      @response = ActionController::TestResponse.new
      @controller = MarkabyController.new
    end

    def test_renders_nothing
      get :renders_nothing
      assert_response :success
    end

    def test_renders_erb_with_explicit_template
      get :renders_erb_with_explicit_template
      assert_response :success
      # TODO: - fix this test environment issue so that assert_template works
      # correctly in these tests
      # assert_template "renders_erb.erb"
    end

    def test_renders_explicit_but_empty_markaby_layout
      get :render_explicit_but_empty_markaby_layout
      assert_response :success

      assert_equal "", @response.body
      # TODO:
      # assert_template "markaby/render_explicit_but_empty_markaby_layout"
    end

    def test_renders_inline_markaby_content
      get :render_inline_content
      assert_response :success
      assert_equal "<ul><li>Scott</li></ul>", @response.body
    end

    def test_renders_mab_template_with_no_values_passed
      get :no_values_passed
      assert_response :success
      assert_equal "<ul><li>Scott</li></ul>", @response.body
    end

    def test_renders_mab_template_with_correct_values
      get :correct_template_values
      assert_response :success

      assert_equal "<ul><li>smt</li><li>joho</li><li>spox</li></ul>", @response.body
    end

    def test_renders_without_explicit_render_call
      get :render_mab_without_explicit_render_call
      assert_response :success

      assert_equal @response.body, "<ul><li>smtlaissezfaire</li></ul>"
    end

    def test_renders_with_ivar
      get :render_with_ivar
      assert_response :success

      assert_equal "<ul><li>smtlaissezfaire</li></ul>", @response.body
    end

    def test_access_to_helpers
      get :access_to_helpers
      assert_response :success

      assert_equal '<a href="/foo">bar</a>', @response.body
    end

    def test_renders_partial_from_template
      get :renders_partial
      assert_response :success

      assert_equal "<ul><li>smtlaissezfaire</li></ul>", @response.body
    end

    def test_renders_partial_with_locals
      get :renders_partial_with_locals
      assert_response :success

      assert_equal "<ul><li>smtlaissezfaire</li></ul>", @response.body
    end

    def test_raises_error_when_template_raises_error
      get :render_which_raises_error

      assert_response :error

      assert_equal ActionView::TemplateError, @controller.last_exception.class
      assert %r(undefined local variable or method `supercalifragilisticexpialidocious' for #<Markaby::.*Builder.*) =~
             @controller.last_exception.message.to_s
    end

    def test_routes_work
      get :routes
      assert_response :success

      expected_output = '<a href="/users/new">Foo</a>'
      assert_equal expected_output, @response.body
    end

    def test_commented_out_template_cant_raise_errors
      get :commented_out_template
      assert_response :success

      expected_output = ""
      assert_equal expected_output, @response.body
    end

    if Rails::VERSION::MAJOR >= 2
      def test_renders_form_for_properly
        get :renders_form_for

        assert_response :success

        assert %r(<form.*></form>) =~ @response.body
      end

      def test_renders_form_for_with_fields_for
        get :render_form_for_with_fields

        assert_response :success

        assert_equal '<form action="/markaby/render_form_for_with_fields" method="post"><input id="foo_foo" name="foo[foo]" size="30" type="text" /></form>',
                     @response.body
      end

      def test_renders_form_for_with_multiple_fields
        get :render_form_for_with_multiple_fields

        assert_response :success

        expected_output =  '<form action="/markaby/render_form_for_with_multiple_fields" method="post">'
        expected_output << '<input id="foo_foo" name="foo[foo]" size="30" type="text" />'
        expected_output << '<input id="foo_baz" name="foo[baz]" size="30" type="text" />'
        expected_output << '</form>'

        assert_equal expected_output,
                     @response.body
      end

      def test_rendering_with_yield_works
        get :render_with_yielding
        assert_response :success

        expected_output = '<div id="main"><p class="hey">hi there</p></div>'
        assert_equal expected_output, @response.body
      end

      def test_render_with_yielding_where_template_has_two_elements
        get :render_with_yielding_where_template_has_two_elements
        assert_response :success

        expected_output = '<div id="main"><p class="hi">hi there</p><p class="hi">hi again</p></div>'
        assert_equal expected_output, @response.body
      end

      def test_render_with_yielding_content_for_block
        get :render_with_yielding_content_for_block
        assert_response :success

        expected_output = '<div id="main"></div><div id="foo"><p>in foo content_for</p></div>'
        assert_equal expected_output, @response.body
      end

      def test_render_content_for_with_block_helper
        get :render_content_for_with_block_helper
        assert_response :success

        expected_output = '<div id="main"></div><div id="foo">'
        expected_output << '<form action="/markaby/render_content_for_with_block_helper" method="post">'
        expected_output << '<input id="foo_foo" name="foo[foo]" size="30" type="text" />'
        expected_output << '</form>'
        expected_output << '</div>'

        assert_equal expected_output, @response.body
      end

      def test_renders_content_for_with_form_for_without_double_render
        get :renders_content_for_with_form_for_without_double_render
        assert_response :success

        expected_output  = '<div id="main"></div><div id="foo">'
        expected_output << '<form action="/markaby/renders_content_for_with_form_for_without_double_render" method="post">'
        expected_output << '<p class="foo">'
        expected_output << '<input id="foo_foo" name="foo[foo]" size="30" type="text" />'
        expected_output << '<input id="foo_submit" name="commit" type="submit" value="foo" />'
        expected_output << '</p>'
        expected_output << '</form>'
        expected_output << '</div>'

        assert_equal expected_output, @response.body
      end

      def test_renders_form_for_with_erb_render_in_body
        get :renders_form_for_with_erb_body
        assert_response :success

        str = '<form action="/markaby/renders_form_for_with_erb_body" method="post">'
        str << '<input id="foo_foo" name="foo[foo]" size="30" type="text" />'
        str << '</form>'

        assert_equal str, @response.body
      end
    end
  end

  describe "rails version" do
    it "should support the current rails version" do
      Markaby::Rails::SUPPORTED_RAILS_VERSIONS.should include(::Rails::VERSION::STRING)
    end
  end
end
