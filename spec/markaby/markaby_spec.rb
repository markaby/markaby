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
          "Giraffes #{small('Miniature')} and #{strong 'Large'}"
        }
        h3 "Donkeys"
        h4 { "Parakeet #{b { i 'Innocent IV' }} in Classic Chartreuse" }
      }
    }

    generated.should == str
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
          "Giraffes #{small('Miniature')} and #{strong 'Large'}"
        }
        h3 "Donkeys"
        h4 { "Parakeet #{b { i 'Innocent IV' }} in Classic Chartreuse" }
      }
    }

    generated.should == str
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
