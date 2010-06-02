module Markaby
  module Rails
    class RailsBuilder < Markaby::Builder
      def form_for(*args, &block)
        @template.form_for(*args) do |__form_for_variable|
          yield(FormHelperProxy.new(self, __form_for_variable))
        end
      end

      alias_method :safe_concat, :concat

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
