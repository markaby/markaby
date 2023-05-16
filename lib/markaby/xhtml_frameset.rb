module Markaby
  class XHTMLFrameset < XmlTagset
    @doctype = ["-//W3C//DTD XHTML 1.0 Frameset//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"]
    @tagset = XHTMLTransitional.tagset.merge({
      frameset: AttrCore + [:rows, :cols, :onload, :onunload],
      frame: AttrCore + [:longdesc, :name, :src, :frameborder, :marginwidth, :marginheight, :noresize, :scrolling]
    })

    @tags = @tagset.keys
    @forms = @tags & FORM_TAGS
    @self_closing = @tags & SELF_CLOSING_TAGS
  end
end
