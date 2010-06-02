require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

class FragmentTest < Test::Unit::TestCase
  it "should have method_missing as a private instance method" do
    private_methods = Markaby::Fragment.private_instance_methods.dup
    private_methods.map! { |m| m.to_sym }

    private_methods.should include(:method_missing)
  end
end
