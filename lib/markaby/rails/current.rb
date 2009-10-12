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
    
    class RailsBuilder < Markaby::Builder
      def form_for(*args, &block)
        @template.form_for(*args) do |__form_for_variable|
          yield(FormHelperProxy.new(self, __form_for_variable))
        end
      end

      # This is used for the block variable given to form_for.  Typically, an erb template looks as so:
      #
      #   <% form_for :foo do |f|
      #     <%= f.text_field :bar %>
      #   <% end %>
      #
      # form_for adds the form tag to the input stream, and assumes that later the user will append
      # the <input> tag to the input stream himself (in erb, this is done with the <%= %> tags).
      #
      # We could do the following in Markaby:
      #
      #   form_for :foo do |f|
      #     text f.text_field(:bar)
      #   end
      #
      # But this is ugly.  This is prettier:
      #
      #   form_for :foo do |f|
      #     f.text_field :bar
      #   end
      class FormHelperProxy
        def initialize(builder, proxied_object)
          @builder = builder
          @proxied_object = proxied_object
        end

        def respond_to?(sym, include_private = false)
          @proxied_object.respond_to?(sym, include_private) || super
        end

      private

        def method_missing(sym, *args, &block)
          result = @proxied_object.__send__(sym, *args, &block)
          @builder.text(result) if result.is_a?(String)
          result
        end
      end
    end
  end
end

ActionView::Template.register_template_handler(:mab, Markaby::Rails::TemplateHandler)