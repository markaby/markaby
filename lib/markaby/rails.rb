if defined?(Rails)
  module Markaby
    module Rails
      class TemplateHandler < ::ActionView::TemplateHandler
        def compile(template, local_assigns={})
          <<-CODE
            handler = Markaby::Rails::TemplateHandler.new
            handler.view = self
            handler.render(lambda { #{template.source} }, local_assigns)
          CODE
        end

        def render(template, local_assigns = (template.respond_to?(:locals) ? template.locals : {}))
          builder = Markaby::Builder.new(instance_variables.merge(local_assigns), @view)

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
    end
  end

  ActionView::Template.register_template_handler(:mab, Markaby::Rails::TemplateHandler)
end