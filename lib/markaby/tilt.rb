require 'tilt'

module Markaby
  module Tilt
    class Template < ::Tilt::Template
      class TiltBuilder < Markaby::Builder
        def __capture_markaby_tilt__(&block)
          __run_markaby_tilt__ do
            text capture(&block)
          end
        end
      end

      def evaluate(scope, locals, &block)
        builder = TiltBuilder.new({}, scope)
        builder.locals = locals

        if block
          builder.instance_eval <<-CODE, __FILE__, __LINE__
            def __run_markaby_tilt__
              #{data}
            end
          CODE

          builder.__capture_markaby_tilt__(&block)
        else
          builder.instance_eval(data, __FILE__, __LINE__)
        end

        builder.to_s
      end

      def prepare; end
    end
  end
end

module Tilt
  MarkabyTemplate = Markaby::Tilt::Template
  register :mab, MarkabyTemplate
end
