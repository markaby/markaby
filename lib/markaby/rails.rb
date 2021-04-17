require 'markaby'

module Markaby
  module Rails
    class TemplateHandler
      class << self
        def register!(options={})
          self.options = options
          ActionView::Template.register_template_handler(:mab, new)
        end

        # TODO: Do we need this?
        # Default format used by Markaby
        # class_attribute :default_format
        # self.default_format = :html

        def options
          @options ||= {}
        end

        def options=(val)
          self.options.merge!(val)
          self.options
        end
      end

      def call(template, source=template.source)
        <<-CODE
          Markaby::Builder.new(Markaby::Rails::TemplateHandler.options, self) do
            #{source}
          end.to_s
        CODE
      end
    end
  end
end
