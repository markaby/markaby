require "markaby/xml_tagset"
require "markaby/xhtml_strict"
module Markaby
  # Additional tags found in XHTML 1.0 Transitional
  class XHTMLTransitional < XmlTagset
    @doctype = ["-//W3C//DTD XHTML 1.0 Transitional//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"]
    @tagset = XHTMLStrict.tagset.merge({
      strike: Attrs,
      center: Attrs,
      dir: Attrs + [:compact],
      noframes: Attrs,
      basefont: [:id, :size, :color, :face],
      u: Attrs,
      menu: Attrs + [:compact],
      iframe: AttrCore + [:longdesc, :name, :src, :frameborder, :marginwidth, :marginheight, :scrolling, :align, :height, :width],
      font: AttrCore + AttrI18n + [:size, :color, :face],
      s: Attrs,
      applet: AttrCore + [:codebase, :archive, :code, :object, :alt, :name, :width, :height, :align, :hspace, :vspace],
      isindex: AttrCore + AttrI18n + [:prompt]
    })

    # Additional attributes found in XHTML 1.0 Transitional
    additional_tags = {
      script: [:language],
      a: [:target],
      td: [:bgcolor, :nowrap, :width, :height],
      p: [:align],
      h5: [:align],
      h3: [:align],
      li: [:type, :value],
      div: [:align],
      pre: [:width],
      body: [:background, :bgcolor, :text, :link, :vlink, :alink],
      ol: [:type, :compact, :start],
      h4: [:align],
      h2: [:align],
      object: [:align, :border, :hspace, :vspace],
      img: [:name, :align, :border, :hspace, :vspace],
      link: [:target],
      legend: [:align],
      dl: [:compact],
      input: [:align],
      h6: [:align],
      hr: [:align, :noshade, :size, :width],
      base: [:target],
      ul: [:type, :compact],
      br: [:clear],
      form: [:name, :target],
      area: [:target],
      h1: [:align]
    }

    additional_tags.each do |k, v|
      @tagset[k] += v
    end

    @tags = @tagset.keys
    @forms = @tags & FORM_TAGS
    @self_closing = @tags & SELF_CLOSING_TAGS
  end
end
