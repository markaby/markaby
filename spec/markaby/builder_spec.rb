require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

module Markaby
  describe Builder do
    before do
      Markaby::Builder.restore_defaults!
    end

    after do
      Markaby::Builder.restore_defaults!
    end

    it "should have method missing as a private method" do
      Markaby::Builder.private_instance_methods.should include("method_missing")
    end
    
    describe "setting options" do
      it "should be able to restore defaults after setting" do
        Markaby::Builder.set :indent, 2
        Markaby::Builder.restore_defaults!
  
        Markaby::Builder.get(:indent).should == 0
      end

      it "should be able to set global options" do
        Markaby::Builder.set :indent, 2
        Markaby::Builder.get(:indent).should == 2
      end
    end
    
    describe "hidden internal variables" do
      # internal clobbering by passed in assigns
      it "should not overwrite internal helpers ivar when assigning a :helpers key" do
        helper = Class.new do
          def some_method
            "a value"
          end
        end.new

        builder = Markaby::Builder.new({:helpers => nil}, helper)
        builder.some_method.should == "a value"
      end
    end
  end
end
