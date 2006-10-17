#
# run `rake test:plugins PLUGIN=markaby` from your RAILS_ROOT
#
require File.join(File.dirname(__FILE__), 'rails', 'test_preamble')

class MarkabyController < ActionController::Base
  @@locals = { :monkeys => Monkey.find(:all) }

  def rescue_action(e) raise e end;

  def partial_rendering
    render :partial => 'monkeys', :locals => @@locals
  end
  
  def partial_rendering_with_stringy_keys_in_local_assigns
    render :partial => 'monkeys', :locals => { 'monkeys' => Monkey.find(:all) }
  end

  def inline_helper_rendering
    render_markaby(:locals => @@locals) { ul { monkeys.each { |m| li m.name } } }
  end
  
  def basic_inline_rendering
    render :inline => mab { ul { @@locals[:monkeys].each { |m| li m.name } } }
  end
end

class MarkabyOnRailsTest < Test::Unit::TestCase
  def setup
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @controller = MarkabyController.new
    @controller.template_root = File.join(File.dirname(__FILE__), 'rails')
  end
  
  def test_partial_rendering
    Markaby::Builder.set :indent, 2
    process :partial_rendering
    expected_html = File.read(File.join(File.dirname(__FILE__), 'rails', 'monkeys.html'))
    assert_response :success
    assert_template 'markaby/_monkeys'
    assert_equal expected_html, @response.body
    
    # From actionpack/lib/action_view/base.rb:
    #   String keys are deprecated and will be removed shortly.
    #
    assert_raises ActionView::TemplateError do
      process :partial_rendering_with_stringy_keys_in_local_assigns
    end
  end

  def test_inline_helper_rendering
    Markaby::Builder.set :indent, 0
    process :inline_helper_rendering
    assert_response :success
    assert_equal '<ul><li>Frank</li><li>Benny</li><li>Paul</li></ul>', @response.body
  end  

  def test_basic_inline_rendering
    Markaby::Builder.set :indent, 0
    process :basic_inline_rendering
    assert_response :success
    assert_equal '<ul><li>Frank</li><li>Benny</li><li>Paul</li></ul>', @response.body
  end  

end
