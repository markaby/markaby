require "markaby/xhtml_transitional"
module Markaby
  class HTML5 < Tagset
    class << self
      def default_options
        super.merge({
          output_xml_instruction: false,
          output_meta_tag: "html5",
          root_attributes: {}
        })
      end

      def custom_element? tag_name
        tag_name.to_s.include? "_"
      end

      def can_handle? tag_name
        custom_element? tag_name
      end

      def handle_tag tag_name, builder, *args, &block
        builder.tag! tag_name, *args, &block
      end

      def validate_and_transform_tag_name! tag_name
        puts "HTML5 VALIDATE TAG NAME #{tag_name}"
        custom_element?(tag_name) ? custom_element_tag_for(tag_name) : super
      end

      def custom_element_tag_for tag_name
        tag_name.to_s.tr("_", "-").to_sym
      end

      def validate_attribute! tag_name, attribute_name
        custom_element?(tag_name) || super
      end
    end

    @doctype = ["html"]
    @tagset = XHTMLTransitional.tagset.merge({
      abbr: Attrs,
      article: Attrs,
      aside: Attrs,
      audio: Attrs,
      bdi: Attrs,
      canvas: Attrs,
      command: Attrs,
      datalist: Attrs,
      details: Attrs,
      embed: Attrs,
      figure: Attrs,
      figcaption: Attrs,
      footer: Attrs,
      header: Attrs,
      hgroup: Attrs,
      keygen: Attrs,
      mark: Attrs,
      menu: Attrs,
      meter: Attrs,
      nav: Attrs,
      output: Attrs,
      progress: Attrs,
      rp: Attrs,
      rt: Attrs,
      ruby: Attrs,
      section: Attrs,
      source: Attrs,
      time: Attrs,
      track: Attrs,
      video: Attrs,
      wbr: Attrs
    })

    # Additional attributes found in HTML5
    additional_tags = {
      a: [:media, :download, :ping],
      area: [:media, :download, :ping, :hreflang, :rel, :type],
      base: [:target],
      button: [:autofocus, :form, :formaction, :formenctype, :formmethod,
        :formnovalidate, :formtarget],
      fieldset: [:form, :disabled, :name],
      form: [:novalidate],
      label: [:form],
      html: [:manifest],
      iframe: [:sandbox, :seamless, :srcdoc],
      img: [:crossorigin],
      input: [:autofocus, :placeholder, :form, :required, :autocomplete,
        :min, :max, :multiple, :pattern, :step, :list, :width, :height,
        :dirname, :formaction, :formenctype, :formmethod,
        :formnovalidate, :formtarget],
      link: [:sizes],
      meta: [:charset],
      menu: [:type, :label],
      object: [:form, :typemustmatch],
      ol: [:reversed],
      output: [:form],
      script: [:async],
      select: [:autofocus, :form, :required],
      style: [:scoped],
      textarea: [:autofocus, :placeholder, :form, :required, :dirname,
        :maxlength, :wrap]
    }

    AttrsHTML5 = [:contenteditable, :contextmentu, :draggable, :dropzone,
      :hidden, :role, :spellcheck, :translate]

    additional_tags.each do |k, v|
      @tagset[k] += v
    end

    @tagset.each do |k, v|
      @tagset[k] += AttrsHTML5
    end

    @tags = @tagset.keys
    @forms = @tags & FORM_TAGS
    @self_closing = @tags & SELF_CLOSING_TAGS
  end
end
