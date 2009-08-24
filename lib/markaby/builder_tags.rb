module Markaby
  module BuilderTags
    (XHTMLTransitional.tags - [:head]).each do |k|
      class_eval <<-CODE, __FILE__, __LINE__
        def #{k}(*args, &block)
          html_tag(#{k.inspect}, *args, &block)
        end
      CODE
    end

    # Builds a head tag.  Adds a <tt>meta</tt> tag inside with Content-Type
    # set to <tt>text/html; charset=utf-8</tt>.
    def head(*args, &block)
      tag!(:head, *args) do
        tag!(:meta, "http-equiv" => "Content-Type", "content" => "text/html; charset=utf-8") if @output_meta_tag
        instance_eval(&block)
      end
    end

    # Builds an html tag.  An XML 1.0 instruction and an XHTML 1.0 Transitional doctype
    # are prepended.  Also assumes <tt>:xmlns => "http://www.w3.org/1999/xhtml",
    # :lang => "en"</tt>.
    def xhtml_transitional(attrs = {}, &block)
      self.tagset = Markaby::XHTMLTransitional
      xhtml_html(attrs, &block)
    end

    # Builds an html tag with XHTML 1.0 Strict doctype instead.
    def xhtml_strict(attrs = {}, &block)
      self.tagset = Markaby::XHTMLStrict
      xhtml_html(attrs, &block)
    end

    # Builds an html tag with XHTML 1.0 Frameset doctype instead.
    def xhtml_frameset(attrs = {}, &block)
      self.tagset = Markaby::XHTMLFrameset
      xhtml_html(attrs, &block)
    end
  end
end