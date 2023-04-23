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

      def can_handle? tag_name
        false
      end

      def handle_tag tag_name, builder, *args, &block
        raise NoMethodError.new
      end

      def validate_and_transform_tag_name! tag_name
        raise(InvalidXhtmlError, "no element `#{tag_name}' for #{doctype}") unless @tagset.has_key?(tag_name)
        tag_name
      end

      def validate_and_transform_attributes! tag_name, *args
        args.last.respond_to?(:to_hash) ? transform_attributes(tag_name, args.last.to_hash) : {}
      end

      def transform_attributes tag_name, attributes
        attributes[:name] ||= attributes[:id] if forms.include?(tag_name) && attributes[:id]
        attributes.transform_keys! { |name| transform_attribute_name name }
        attributes.reject! { |name, value| name.nil? || (AttrsBoolean.include?(name) && value.nil?) }
        attributes.keys.each { |name| validate_attribute! tag_name, name }
        attributes
      end

      def transform_attribute_name name
        name.to_s.downcase.tr("_", "-").to_sym
      end

      def validate_attribute! tag_name, attribute_name
        raise InvalidXhtmlError, "no attribute `#{attribute_name}' on #{tag_name} elements" unless valid_attribute_name? tag_name, attribute_name
      end

      def valid_attribute_name? tag_name, attribute_name
        attribute_name.to_s.start_with?(":", "data-", "aria-") || @tagset[tag_name].include?(attribute_name)
      end
    end
  end
end
