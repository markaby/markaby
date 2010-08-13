module Markaby
  module Rails
    class RailsBuilder < Markaby::Builder
      def form_for(*args, &block)
        @_helper.output_buffer = OutputBuffer.new

        @template.form_for(*args) do |__form_for_variable|
          yield FormHelperProxy.new(@_helper, __form_for_variable)
        end

        text(@_helper.output_buffer)
      end

      alias_method :safe_concat, :concat

      # Rails 2.3.6 calls safe_concat on the output buffer.
      # Future versions of rails alias safe_concat to concat on the core
      # class String.
      #
      # Obviously, that's a bad idea.  Thanks a ton, Rails.
      class OutputBuffer < String
        alias_method :safe_concat, :concat
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
        def initialize(view, proxied_object)
          @view           = view
          @proxied_object = proxied_object
        end

        def respond_to?(sym, include_private = false)
          @proxied_object.respond_to?(sym, include_private) || super
        end

      private

        def method_missing(sym, *args, &block)
          result = @proxied_object.__send__(sym, *args, &block)
          @view.concat(result)
          result
        end
      end
    end
  end
end
