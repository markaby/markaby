module Markaby
  class Builder

    def initialize(assigns, helpers, &block)
      @builder, @helpers = ::Builder::XmlMarkup.new(:indent => 2), helpers
      for iv in helpers.instance_variables
        instance_variable_set(iv, helpers.instance_variable_get(iv))
      end
      for iv, val in assigns
        instance_variable_set("@#{iv}", val)
      end

      if block
        instance_eval &block
      end
    end

    def to_s
      @builder.target!
    end

    def text(string)
      @builder << string.to_s
      nil
    end
    alias_method :<<, :text

    def tag!(tag, *args, &block)
      @builder.method_missing(tag, *args, &block)
    end

    def method_missing(tag, *args, &block)
      if (TAGS + BIG_TAGS).include?(tag)
        if args.empty? and block.nil?
          return CssProxy.new do |args, block|
            tag!(tag, *args, &block)
          end
        end
      end

      if TAGS.include?(tag)
        tag!(tag, *args, &block)
      elsif BIG_TAGS.include?(tag)
        tag!(tag, *args, &block)
      elsif SELF_CLOSING_TAGS.include?(tag)
        tag!(tag, *args)
      elsif instance_variable_get("@#{tag}")
        instance_variable_get("@#{tag}")
      elsif @helpers.respond_to?(tag)
        text @helpers.send(tag, *args, &block)
      else
        tag!(tag, *args, &block)
      end
    end

    def p(*args, &block)
      method_missing(:p, *args, &block)
    end

    def head
      tag!(:head) do
        tag!(:meta, 'http-equiv' => 'Content-Type', 'content' => 'text/html; charset=utf-8')
        yield
      end
    end

    def html(*args, &block)
      if args.empty?
        args = ["-//W3C//DTD XHTML 1.0 Transitional//EN", "DTD/xhtml1-transitional.dtd"]
      end
      @builder.instruct!
      @builder.declare!(:DOCTYPE, :html, :PUBLIC, *args)
      tag!(:html, :xmlns => "http://www.w3.org/1999/xhtml",
        "xml:lang" => "en", :lang => "en", &block)
    end
    alias_method :xhtml_transitional, :html

    def xhtml_strict(&block)
      html("-//W3C//DTD XHTML 1.0 Transitional//EN", "DTD/xhtml1-transitional.dtd", &block)
    end
  end
end
