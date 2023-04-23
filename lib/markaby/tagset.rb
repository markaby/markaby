module Markaby
  FORM_TAGS = [:form, :input, :select, :textarea]
  SELF_CLOSING_TAGS = [:area, :base, :br, :col, :command, :embed, :frame, :hr,
    :img, :input, :keygen, :link, :meta, :param, :source,
    :track, :wbr]

  # Common sets of attributes.
  AttrCore = [:id, :class, :style, :title]
  AttrI18n = [:lang, :"xml:lang", :dir]
  AttrEvents = [:onclick,
    :ondblclick,
    :onmousedown,
    :onmouseup,
    :onmouseover,
    :onmousemove,
    :onmouseout,
    :onkeypress,
    :onkeydown,
    :onkeyup]
  AttrFocus = [:accesskey, :tabindex, :onfocus, :onblur]
  AttrHAlign = [:align, :char, :charoff]
  AttrVAlign = [:valign]
  Attrs = AttrCore + AttrI18n + AttrEvents

  AttrsBoolean = [
    :checked, :disabled, :multiple, :readonly, :selected, # standard forms
    :autofocus, :required, :novalidate, :formnovalidate, # HTML5 forms
    :defer, :ismap, # <script defer>, <img ismap>
    :compact, :declare, :noresize, :noshade, :nowrap # deprecated or unused
  ]
  class Tagset
    class << self
      attr_accessor :tags, :tagset, :forms, :self_closing, :doctype

      def default_options
        {tagset: self}
      end

      def can_handle? tag
        false
      end

      def handle_tag tag, builder, *args, &block
        raise NoMethodError.new
      end

      def validate_and_transform_tag_name! tag
        @tagset.has_key?(tag) ? tag : raise(InvalidXhtmlError, "no element `#{tag}' for #{doctype}")
      end

      def validate_and_transform_attributes! tag, *args
        args.last.respond_to?(:to_hash) ? transform_attributes(tag, args.last.to_hash) : {}
      end

      def transform_attributes tag, attrs
        attrs[:name] ||= attrs[:id] if forms.include?(tag) && attrs[:id]
        attrs.each do |key, value|
          name = transform_attribute_name key
          validate_attribute! tag, name
          attrs[key] = transform_boolean_attribute(name, value) if AttrsBoolean.include? name
        end
        attrs.compact
      end

      # (@tagset == Markaby::HTML5 && atname.to_s =~ /^data-/)
      def transform_attribute_name name
        name.to_s.downcase.tr("_", "-").intern
      end

      def validate_attribute! tag, name
        raise InvalidXhtmlError, "no attribute `#{name}' on #{tag} elements" unless valid_attribute_name? tag, name
      end

      def valid_attribute_name? tag, name
        name.start_with?(":", "data-") || @tagset[tag].include?(name)
      end

      def transform_boolean_attribute name, value
        value ? name.to_s : nil
      end
    end
  end
end
