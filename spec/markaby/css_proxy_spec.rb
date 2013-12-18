require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Markaby::CssProxy do
  it "should have method_missing as private" do
    methods = Markaby::CssProxy.private_instance_methods.dup
    methods.map! { |m| m.to_sym }

    methods.should include(:method_missing)
  end

  def mock_builder
    mock_builder = Class.new do
      def tag!(*args); end
    end.new
  end

  it "responds_to_everything" do
    proxy = Markaby::CssProxy.new(mock_builder, 'stream', :sym)
    proxy.respond_to?(:any_method).should be_true
    proxy.respond_to?(:foobarbazasdfasdfadfs).should be_true
  end

  it "does_not_respond_to_method_missing" do
    proxy = Markaby::CssProxy.new(mock_builder, 'stream', :sym)
    proxy.should_not respond_to(:method_missing)
  end

  it "does_respond_to_private_instance_methods_with_private_flag_set_to_true" do
    proxy = Markaby::CssProxy.new(mock_builder, 'stream', :sym)
    proxy.respond_to?(:method_missing, true).should be_true
  end

  it "does_not_respond_to_private_instance_methods_with_private_flag_set_to_false" do
    proxy = Markaby::CssProxy.new(mock_builder, 'stream', :sym)
    proxy.respond_to?(:method_missing, false).should be_false
  end

  it "respond_to_should_always_return_boolean" do
    proxy = Markaby::CssProxy.new(mock_builder, 'stream', :sym)
    proxy.respond_to?(:method_missing, :a_value).should be_true
  end
end
