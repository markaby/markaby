require 'markaby/rails/rails_builder'

module Markaby
  module Rails
    class TemplateHandler < ::ActionView::TemplateHandler
      include ActionView::TemplateHandlers::Compilable

      def compile(template, local_assigns={})
        <<-CODE
          handler = Markaby::Rails::TemplateHandler.new
          handler.view = self
          handler.render(lambda {
            #{template.source}
          }, local_assigns)
        CODE
      end

      def render(template, local_assigns = (template.respond_to?(:locals) ? template.locals : {}))
        builder = RailsBuilder.new(instance_variables.merge(local_assigns), @view)
        @view.output_buffer = builder

        template.is_a?(Proc) ?
          builder.instance_eval(&template) :
          builder.instance_eval(template.source)

        builder.to_s
      end

      attr_accessor :view

    private

      def instance_variables
        instance_variable_hash(@view)
      end

      def instance_variable_hash(object)
        returning Hash.new do |hash|
          object.instance_variables.each do |var_name|
            hash[var_name.gsub("@", "")] = object.instance_variable_get(var_name)
          end
        end
      end
    end

    module Helpers
      # allow fragments to act as strings.  url_for has a
      # case statment in it:
      #
      # case options
      # when String
      #   ...
      #
      # which essential is doing the following:
      #
      # String === options
      #
      # That assertion fails with Markaby::Fragments, which are essential
      # builder/string fragments.
      #
      def url_for(options={})
        case options
        when Markaby::Fragment
          super(options.to_s)
        else
          super
        end
      end

      def capture(*args, &block)
        if output_buffer.kind_of?(Markaby::Builder)
          output_buffer.capture(&block)
        else
          super
        end
      end
    end
  end
end

ActionView::Base.class_eval do
  include Markaby::Rails::Helpers
end

ActionView::Template.register_template_handler(:mab, Markaby::Rails::TemplateHandler)
