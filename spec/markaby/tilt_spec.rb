require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require 'tilt'

module Markaby
  describe Tilt, "templates" do
    before do
      @block = lambda do |t|
        File.read(File.dirname(__FILE__) + "/#{t.file}")
      end
    end

    it "should have the constant ::Tilt::Markaby after registration" do
      lambda {
        ::Tilt::MarkabyTemplate
      }.should_not raise_error
    end

    it "should be able to render an erb template" do
      tilt = ::Tilt::ERBTemplate.new("tilt/erb.erb", &@block)
      tilt.render.should == "hello from erb!"
    end

    it "should be able to render a markaby template with static html" do
      tilt = ::Tilt::MarkabyTemplate.new("tilt/markaby.mab", &@block)
      tilt.render.should == "hello from markaby!"
    end

    it "should use the contents of the template" do
      tilt = ::Tilt::MarkabyTemplate.new("tilt/markaby_other_static.mab", &@block)
      tilt.render.should == "_why?"
    end

    it "should render from a string (given as data)" do
      tilt = ::Tilt::MarkabyTemplate.new { "html do; end" }
      tilt.render.should == "<html></html>"
    end

    it "should evaluate a template file in the scope given" do
      scope = mock 'scope object', :foo => "bar"

      tilt = ::Tilt::MarkabyTemplate.new("tilt/scope.mab", &@block)
      tilt.render(scope).should == "<li>bar</li>"
    end

    it "should pass locals to the template" do
      tilt = ::Tilt::MarkabyTemplate.new("tilt/locals.mab", &@block)
      tilt.render(Object.new, { :foo => "bar" }).should == "<li>bar</li>"
    end

    it "should yield to the block given" do
      tilt = ::Tilt::MarkabyTemplate.new("tilt/yielding.mab", &@block)
      eval_scope = Markaby::Builder.new

      output = tilt.render(Object.new, {}) do
        text("Joe")
      end

      output.should == "Hey Joe"
    end

    it "should be able to render two templates in a row" do
      tilt = ::Tilt::MarkabyTemplate.new("tilt/render_twice.mab", &@block)

      tilt.render.should == "foo"
      tilt.render.should == "foo"
    end

    it "should retrieve a Tilt::MarkabyTemplate when calling Tilt['hello.mab']" do
#      ::Tilt['./tilt/markaby.mab'].should == Markaby::Tilt::Template
      ::Tilt['./tilt/markaby.mab'].should == ::Tilt::MarkabyTemplate # isn't this how above spec actually reads?
    end

    it "should return a new instance of the implementation class (when calling Tilt.new)" do
#      ::Tilt.new(File.dirname(__FILE__) + "/tilt/markaby.mab").should be_a_kind_of(Markaby::Tilt::Template)
      ::Tilt.new(File.dirname(__FILE__) + "/tilt/markaby.mab").should be_a_kind_of(::Tilt::MarkabyTemplate)
    end
  end
end
