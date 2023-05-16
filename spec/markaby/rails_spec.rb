require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

# stub
module ActionView
  module Template
    class << self
      def register_template_handler(sym, handler)
        @template_handlers ||= {}
        @template_handlers[sym] = handler
      end

      def template_handlers
        @template_handlers ||= {}
      end
    end
  end
end

describe Markaby::Rails do
  it "should register the template handler" do
    Markaby::Rails::TemplateHandler.register!
    ActionView::Template.template_handlers[:mab].should be_a_kind_of(Markaby::Rails::TemplateHandler)
  end

  it "should be able to pass options" do
    Markaby::Rails::TemplateHandler.register!(indent: 2)
    Markaby::Rails::TemplateHandler.options[:indent].should == 2
  end
end
