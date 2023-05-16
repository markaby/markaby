require "markaby/tagset"
module Markaby
  # Additional tags found in XHTML 1.0 Frameset
  class XmlTagset < Tagset
    class << self
      def default_options
        super.merge({
          output_xml_instruction: true,
          output_meta_tag: "xhtml",
          root_attributes: {
            xmlns: "http://www.w3.org/1999/xhtml",
            "xml:lang": "en",
            lang: "en"
          }
        })
      end
    end
  end
end
