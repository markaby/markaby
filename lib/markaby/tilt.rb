require 'tilt'

module Markaby
  module Tilt
    class Template < ::Tilt::Template
      def evaluate(scope, locals, &block)
        @builder.helper = scope
        @builder.locals = locals
        @builder.instance_eval(data, __FILE__, __LINE__)
        @builder.to_s
      end

      def compile!
        @builder = Markaby::Builder.new
      end
    end
  end
end

module Tilt
  MarkabyTemplate = ::Markaby::Tilt::Template
  register "mab", MarkabyTemplate
end
