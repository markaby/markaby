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
      private_methods = Markaby::Builder.private_instance_methods.dup
      private_methods.map! { |m| m.to_sym }
      private_methods.should include(:method_missing)
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

    describe "evaluating blocks" do
      it "should evaluate a pure-string block (without requiring a call to the text method)" do
        b = Builder.new do
          "foo"
        end

        b.to_s.should == "foo"
      end

      it "should only evaluate the last argument in a pure-string block" do
        b = Builder.new do
          "foo"
          "bar"
        end

        b.to_s.should == "bar"
      end

      it "should evaluate pure-strings inside an tag" do
        b = Builder.new do
          h1 do
            "foo"
          end
        end

        b.to_s.should == "<h1>foo</h1>"
      end

      it "should ignore a pure string in the block, even if comes last, if there has been any markup whatsoever" do
        b = Builder.new do
          h1
          "foo"
        end

        b.to_s.should == "<h1/>"
      end
    end

    describe "capture" do
      before do
        @builder = Builder.new
      end

      it "should return the string captured" do
        out = @builder.capture do
          h1 "TEST"
          h2 "CAPTURE ME"
        end

        out.should == "<h1>TEST</h1><h2>CAPTURE ME</h2>"
      end

      it "should not change the output buffer" do
        lambda {
          @builder.capture do
            h1 "FOO!"
          end
        }.should_not change { @builder.to_s }
      end

      it "should be able to capture inside a capture" do
        out = @builder.capture do
          capture do
            h1 "foo"
          end
        end

        out.should == "<h1>foo</h1>"
      end
    end
  end
end
