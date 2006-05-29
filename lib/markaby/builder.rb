module Markaby
  # The Markaby::Builder class is the central gear in the system.  When using
  # from Ruby code, this is the only class you need to instantiate directly.
  #
  #   mab = Markaby::Builder.new
  #   mab.html do
  #     head { title "Boats.com" }
  #     body do
  #       h1 "Boats.com has great deals"
  #       ul do
  #         li "$49 for a canoe"
  #         li "$39 for a raft"
  #         li "$29 for a huge boot that floats and can fit 5 people"
  #       end
  #     end
  #   end
  #   puts mab.to_s
  #
  class Builder

    @@default = {
      :indent => 2,
      :output_helpers => true,
      :output_meta_tag => true,
      :image_tag_options => { :border => '0', :alt => '' }
    }

    def self.set(option, value)
      @@default[option] = value
    end

    XHTMLTransitional = ["-//W3C//DTD XHTML 1.0 Transitional//EN", "DTD/xhtml1-transitional.dtd"]
    
    XHTMLStrict = ["-//W3C//DTD XHTML 1.0 Strict//EN", "DTD/xhtml1-strict.dtd"]

    attr_accessor :output_helpers

    # Create a Markaby builder object.  Pass in a hash of variable assignments to
    # +assigns+ which will be available as instance variables inside tag construction
    # blocks.  If an object is passed in to +helpers+, its methods will be available
    # from those same blocks.
    #
    # Pass in a +block+ to new and the block will be evaluated.
    #
    #   mab = Markaby::Builder.new {
    #     html do
    #       body do
    #         h1 "Matching Mole"
    #       end
    #     end
    #   }
    #
    def initialize(assigns = {}, helpers = nil, &block)
      @streams = [[]]
      @assigns = assigns
      @margin = -1

      @indent = @@default[:indent]
      @output_helpers = @@default[:output_helpers]
      @output_meta_tag = @@default[:output_meta_tag]

      use_tagset Markaby::XHTMLTransitionalTags

      if helpers
        @helpers = helpers.dup
        for iv in helpers.instance_variables
          instance_variable_set(iv, helpers.instance_variable_get(iv))
        end
      end

      unless assigns.nil? || assigns.empty?
        for iv, val in assigns
          instance_variable_set("@#{iv}", val)
          unless @helpers.nil?
            @helpers.instance_variable_set("@#{iv}", val)
          end
        end
      end

      @margin += 1
      @builder = ::Builder::XmlMarkup.new(:indent => @indent, :margin => @margin, :target => @streams.last)

      def @builder.target=(io)
        @target = io
      end

      instance_eval(&block) if block
    end

    # Returns a string containing the HTML stream.  Internally, the stream is stored as an Array.
    def to_s
      @streams.last.join
    end

    # Write a +string+ to the HTML stream without escaping it.
    def text(string)
      @builder << "#{string}"
      nil
    end
    alias_method :<<, :text
    alias_method :concat, :text

    # Emulate ERB to satisfy helpers like <tt>form_for</tt>.
    def _erbout; self end

    # Captures the HTML code built inside the +block+.  This is done by creating a new
    # stream for the builder object, running the block and passing back its stream as a string.
    #
    #   >> Markaby::Builder.new.capture { h1 "TEST"; h2 "CAPTURE ME" }
    #   => "<h1>TITLE</h1>\n<h2>CAPTURE ME</h2>\n"
    #
    def capture(&block)
      @streams.push(builder.target = [])
      str = instance_eval(&block)
      str = to_s unless @streams.last.compact.empty?
      @streams.pop
      builder.target = @streams.last
      str
    end

    # Content_for will store the given block in an instance variable for later use 
    # in another template or in the layout.
    #
    # The name of the instance variable is content_for_<name> to stay consistent 
    # with @content_for_layout which is used by ActionView's layouts.
    #
    # Example:
    #
    #   content_for("header") do
    #     h1 "Half Shark and Half Lion"
    #   end
    #
    # If used several times, the variable will contain all the parts concatenated.
    def content_for(name, &block)
      eval "@content_for_#{name} = (@content_for_#{name} || '') + capture(&block)"
    end

    # Create a tag named +tag+. Other than the first argument which is the tag name,
    # the arguments are the same as the tags implemented via method_missing.
    def tag!(tag, *args, &block)
      if @tagset
        if !@tagset.has_key?(tag)
          raise InvalidXhtmlError, "no element `#{tag}' for #{doctype}"
        elsif args.last.respond_to?(:to_hash)
          attrs = args.last.to_hash
          attrs.each do |k, v|
            unless k =~ /:/ or @tagset[tag].include? k.to_s.downcase.intern
              raise InvalidXhtmlError, "no attribute `#{k}' on #{tag} elements"
            end
          end
        end
      end
      if block
        str = capture &block
        block = proc { text(str) }
      end
      fragment { @builder.method_missing(tag, *args, &block) }
    end

    # Create XML markup based on the name of the method +sym+. This method is never 
    # invoked directly, but is called for each markup method in the markup block.
    #
    # This method is also used to intercept calls to helper methods and instance
    # variables.  Here is the order of interception:
    #
    # * If +sym+ is a helper method, the helper method is called
    #   and output to the stream.
    # * If +sym+ is a recognized HTML tag, the tag is output
    #   or a CssProxy is returned if no arguments are given.
    # * If +sym+ appears to be a self-closing tag, its block
    #   is ignored, thus outputting a valid self-closing tag.
    # * If +sym+ is also the name of an instance variable, the
    #   value of the instance variable is returned.
    # * Otherwise, +sym+ and its arguments are passed to tag!
    def method_missing(sym, *args, &block)
      if @helpers.respond_to?(sym)
        r = @helpers.send(sym, *args, &block)
        @output_helpers ? fragment { @builder << r } : r
      elsif ::Builder::XmlMarkup.instance_methods.include?(sym.to_s)
        @builder.__send__(sym, *args, &block)
      elsif @tagset and @tagset_tags.include?(sym)
        if @tagset_self_closing.include?(sym) and block
          raise InvalidXhtmlError, "the `#{sym}' element is self-closing, please remove the block"
        end
        if args.empty? and block.nil? and not NO_PROXY.include?(sym)
          return CssProxy.new do |args, block|
            if @tagset_forms.include?(sym) and args.last.respond_to?(:to_hash) and args.last[:id]
              args.last[:name] ||= args.last[:id]
            end
            tag!(sym, *args, &block)
          end
        end
        if not @tagset_self_closing.include?(sym) and args.first.respond_to?(:to_hash)
          block ||= proc{}
        end
        tag!(sym, *args, &block)
      elsif instance_variable_get("@#{sym}")
        instance_variable_get("@#{sym}")
      elsif @tagset.nil?
        tag!(sym, *args, &block)
      else
        raise NoMethodError, "no such method `#{sym}'"
      end
    end

    undef_method :p, :select, :sub

    # Builds a image tag.  Assumes <tt>:border => '0', :alt => ''</tt>.
    def img(opts = {})
      tag!(:img, @@default[:image_tag_options].merge(opts))
    end

    # Builds a head tag.  Adds a <tt>meta</tt> tag inside with Content-Type
    # set to <tt>text/html; charset=utf-8</tt>.
    def head(*args, &block)
      tag!(:head, *args) do
        tag!(:meta, "http-equiv" => "Content-Type", "content" => "text/html; charset=utf-8") if @output_meta_tag
        instance_eval &block
      end
    end

    def use_tagset(tagset)
      return if @tagset == tagset
      @tagset = tagset
      @tagset_tags = tagset.keys
      @tagset_forms = @tagset_tags & FORM_TAGS
      @tagset_self_closing = @tagset_tags & SELF_CLOSING_TAGS
    end

    # Builds an html tag.  An XML 1.0 instruction and an XHTML 1.0 Transitional doctype
    # are prepended.  Also assumes <tt>:xmlns => "http://www.w3.org/1999/xhtml",
    # :lang => "en"</tt>.
    def html(*doctype, &block)
      if doctype.empty?
        doctype = XHTMLTransitional
        use_tagset Markaby::XHTMLTransitionalTags
      end
      declare!(:DOCTYPE, :html, :PUBLIC, *doctype)
      tag!(:html, :xmlns => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", :lang => "en", &block)
    end
    alias_method :xhtml_transitional, :html

    # Builds an html tag with XHTML 1.0 Strict doctype instead.
    def xhtml_strict(&block)
      use_tagset Markaby::XHTMLStrictTags
      instruct!
      html *XHTMLStrict, &block
    end

    private

    def fragment
      stream = @streams.last
      f1 = stream.length
      yield
      f2 = stream.length - f1
      Fragment.new(stream, f1, f2)
    end

  end

  class Fragment < ::Builder::BlankSlate
    def initialize(s, a, b)
      @s, @f1, @f2 = s, a, b
    end
    def method_missing(*a)
      unless @str
        @str = @s[@f1, @f2].to_s
        @s[@f1, @f2] = [nil] * @f2
        @str
      end
      @str.send(*a)
    end
  end

end
