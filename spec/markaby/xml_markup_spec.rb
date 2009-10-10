require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

module Markaby
  describe XmlMarkup do
    it "should have method_missing as private" do
      XmlMarkup.private_instance_methods.should include("method_missing")
    end
  end
end
