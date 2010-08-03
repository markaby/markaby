require 'markaby/rails/rails_builder'

module Markaby
  module Rails
    class TemplateHandler < ::ActionView::TemplateHandler
      include ActionView::TemplateHandlers::Compilable

      def compile(template, local_assigns={})
        <<-CODE
          handler = Markaby::Rails::TemplateHandler.new
          handler.view = self
          handler.render(lambda { #{template.source} }, local_assigns)
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
  end
end

# allow fragments to act as strings.  url_for has a
# nasty case statment in it:
#
# case options
# when String
#   ...
#
# which essential is doing the following:
#
# String === options
#
# We prefer to override url_for rather than String#===
#
ActionView::Helpers::UrlHelper.class_eval do
  alias_method :url_for_aliased_by_markaby, :url_for

  def url_for(options={})
    options ||= {}

    url = case options
    when Markaby::Fragment
      url_for_aliased_by_markaby(options.to_s)
    else
      url_for_aliased_by_markaby(options)
    end
  end
end

ActionView::Template.register_template_handler(:mab, Markaby::Rails::TemplateHandler)
