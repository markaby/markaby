require 'tilt'

module Markaby
  module Tilt
    class Template < ::Tilt::Template
      def evaluate(scope, locals, &block)
        builder = Markaby::Builder.new
        builder.helper = scope
        builder.locals = locals
        builder.instance_eval(data, __FILE__, __LINE__)
        builder.to_s
      end

      def compile!; end
    end
  end
end

module Tilt
  MarkabyTemplate = Markaby::Tilt::Template
  register "mab", MarkabyTemplate
end
