module Markaby
  module Rails
    class TemplateHandler < ::ActionView::TemplateHandler
      def render(template, local_assigns={})
        builder = Markaby::Builder.new(instance_variables.merge(local_assigns), @view)
        builder.instance_eval(template.source)
        builder.to_s
      end
      
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