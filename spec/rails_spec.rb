require File.join(File.dirname(__FILE__), 'rails', 'test_helper')

if RUNNING_RAILS
  class MarkabyOnRailsTest < ActionController::TestCase
    class TestController < ActionController::Base
      VIEW_PATH = File.expand_path(File.join(File.dirname(__FILE__), 'rails', 'markaby'))

      # Rails will by default look for a directory named "markaby_on_rails_test/markaby -
      # because this controller is named MarkabyOnRailsTest::MarkabyController.  Override
      # this so that we can just use the regular view path in our tests
      def self.controller_path
        VIEW_PATH
      end

      around_filter :catch_exceptions

      attr_reader :last_exception

      def catch_exceptions
        yield
      rescue Exception => @last_exception
        raise @last_exception
      end
    end

    class MarkabyController < TestController
      def renders_nothing
        render :text => ""
      end

      def renders_erb_with_explicit_template
        render :template => "renders_erb"
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
        render :template => "render_explicit_but_empty_markaby_layout.mab"
      end

      def no_values_passed
        render :template => "no_values_passed"
      end

      def correct_template_values
        render :template => "correct_template_values"
      end

      def render_erb_without_explicit_render_call
      end

      # TODO: See test below
      # def render_without_explicit_render_call
      # end

      def render_with_ivar
        @user = "smtlaissezfaire"
        render :template => "render_with_ivar"
      end

      def access_to_helpers
        render :template => "access_to_helpers"
      end

      def renders_partial
        render :template => "partial_parent"
      end

      def renders_partial_with_locals
        render :template => "partial_parent_with_locals"
      end

      def render_which_raises_error
        render :template => "broken"
      end
    end

    def setup
      Markaby::Builder.restore_defaults!
      MarkabyController.view_paths = MarkabyController::VIEW_PATH

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

    # TODO:
    #   Fix the following test environment issue so that the following
    #   test will run
    #
    #
    # def test_renders_default_erb_without_explicit_render_call
    #   get :render_erb_without_explicit_render_call
    #   assert_response :success
    #   
    #   assert_equal "hello, from erb"
    # end
    # 
    # def test_renders_without_explicit_render_call
    #   get :render_without_explicit_render_call
    #   assert_response :success
    #   
    #   assert_equal "<ul><li>smtlaissezfaire</li></ul>", @response.body
    # end

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
      assert %r(undefined local variable or method `supercalifragilisticexpialidocious' for #<Markaby::Builder.*) =~
             @controller.last_exception.message
    end
  end
end