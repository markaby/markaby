require "markaby/tagset"
require "markaby/builder_tags"

module Markaby
  RUBY_VERSION_ID = RUBY_VERSION.split(".").join.to_i

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
    include Markaby::BuilderTags
    GENERIC_OPTIONS = {
      indent: 0,
      auto_validation: true
    }

    HTML5_OPTIONS = HTML5.default_options.dup
    DEFAULT_OPTIONS = GENERIC_OPTIONS.merge(HTML5_OPTIONS)

    @@options = DEFAULT_OPTIONS.dup

    def self.restore_defaults!
      @@options = DEFAULT_OPTIONS.dup
    end

    def self.set(option, value)
      @@options[option] = value
    end

    def self.get(option)
      @@options[option]
    end

    attr_reader :tagset

    def tagset=(tagset)
      @tagset = tagset

      tagset.default_options.each do |k, v|
        instance_variable_set("@#{k}".to_sym, v)
      end
    end

    # Create a Markaby builder object.  Pass in a hash of variable assignments to
    # +assigns+ which will be available as instance variables inside tag construction
    # blocks.  If an object is passed in to +helper+, its methods will be available
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
    def initialize(assigns = {}, helper = nil, &block)
      @streams = [Stream.new]
      @assigns = assigns.dup
      @_helper = helper
      @used_ids = {}

      @@options.each do |k, v|
        instance_variable_set("@#{k}", @assigns.delete(k) || v)
      end

      @assigns.each do |k, v|
        instance_variable_set("@#{k}", v)
      end

      helper&.instance_variables&.each do |iv|
        instance_variable_set(iv, helper.instance_variable_get(iv))
      end

      @builder = XmlMarkup.new(indent: @indent, target: @streams.last)

      text(capture(&block)) if block
    end

    def helper=(helper)
      @_helper = helper
    end

    def metaclass(&block)
      metaclass = class << self; self; end
      metaclass.class_eval(&block)
    end

    private :metaclass

    def locals=(locals)
      locals.each do |key, value|
        metaclass do
          define_method key do
            value
          end
        end
      end
    end

    # Returns a string containing the HTML stream.  Internally, the stream is stored as an Array.
    def to_s
      @streams.last.to_s
    end

    # Write a +string+ to the HTML stream without escaping it.
    def text(string)
      @builder << string.to_s
      nil
    end
    alias_method :<<, :text
    alias_method :concat, :text

    # Captures the HTML code built inside the +block+.  This is done by creating a new
    # stream for the builder object, running the block and passing back its stream as a string.
    #
    #   >> Markaby::Builder.new.capture { h1 "TEST"; h2 "CAPTURE ME" }
    #   => "<h1>TEST</h1><h2>CAPTURE ME</h2>"
    #
    def capture(&block)
      @streams.push(@builder.target = Stream.new)
      @builder.level += 1
      str = instance_eval(&block)
      str = @streams.last.join if @streams.last.any?
      @streams.pop
      @builder.level -= 1
      @builder.target = @streams.last
      str
    end

    # Create a tag named +tag+. Other than the first argument which is the tag name,
    # the arguments are the same as the tags implemented via method_missing.
    def tag!(tag, *args, &block)
      attributes = {}
      if @auto_validation && @tagset
        tag = @tagset.validate_and_transform_tag_name! tag
        attributes = @tagset.validate_and_transform_attributes!(tag, *args)
      end
      element_id = attributes[:id].to_s
      raise InvalidXhtmlError, "id `#{element_id}' already used (id's must be unique)." if @used_ids.has_key?(element_id)
      if block
        str = capture(&block)
        block = proc { text(str) }
      end

      f = fragment { @builder.tag!(tag, *args, &block) }
      @used_ids[element_id] = f unless element_id.empty?
      f
    end

    private

    # This method is used to intercept calls to helper methods and instance
    # variables.  Here is the order of interception:
    #
    # * If +sym+ is a helper method, the helper method is called
    #   and output to the stream.
    # * If +sym+ is a Builder::XmlMarkup method, it is passed on to the builder object.
    # * If +sym+ is also the name of an instance variable, the
    #   value of the instance variable is returned.
    # * If +sym+ has come this far and no +tagset+ is found, +sym+ and its arguments are passed to tag!
    # * If a tagset is found, the tagset is tole to handle +sym+
    #
    # method_missing used to be the lynchpin in Markaby, but it's no longer used to handle
    # HTML tags.  See html_tag for that.
    def method_missing(sym, *args, &block)
      case response_for(sym)
      when :helper then @_helper.send(sym, *args, &block)
      when :assigns then @assigns[sym]
      when :stringy_assigns then @assigns[sym.to_s]
      when :ivar then instance_variable_get(ivar)
      when :helper_ivar then @_helper.instance_variable_get(ivar)
      when :xml_markup then @builder.__send__(sym, *args, &block)
      when :tag then tag!(sym, *args, &block)
      when :tagset then @tagset.handle_tag sym, self, *args, &block
      else super
      end
    end

    def response_for sym
      return :helper if @_helper.respond_to?(sym, true)
      return :assigns if @assigns.has_key?(sym)
      return :stringy_assigns if @assigns.has_key?(sym.to_s)
      return :ivar if instance_variables_for(self).include?(ivar = "@#{sym}".to_sym)
      return :helper_ivar if @_helper && instance_variables_for(@_helper).include?(ivar)
      return :xml_markup if instance_methods_for(::Builder::XmlMarkup).include?(sym)
      return :tag if @tagset.nil?
      return :tagset if @tagset.can_handle? sym
      nil
    end

    def respond_to_missing? sym, include_private = false
      !response_for(sym).nil?
    end

    if RUBY_VERSION_ID >= 191
      def instance_variables_for(obj)
        obj.instance_variables
      end

      def instance_methods_for(obj)
        obj.instance_methods
      end
    else
      def instance_variables_for(obj)
        obj.instance_variables.map { |var| var.to_sym }
      end

      def instance_methods_for(obj)
        obj.instance_methods.map { |m| m.to_sym }
      end
    end

    def fragment
      stream = @streams.last
      start = stream.length
      yield
      length = stream.length - start
      Fragment.new(stream, start, length)
    end
  end

  class Stream < Array
    alias_method :to_s, :join
  end

  # Every tag method in Markaby returns a Fragment.  If any method gets called on the Fragment,
  # the tag is removed from the Markaby stream and given back as a string.  Usually the fragment
  # is never used, though, and the stream stays intact.
  #
  # For a more practical explanation, check out the README.
  class Fragment < ::Builder::BlankSlate
    def initialize(*args)
      @stream, @start, @length = args
      @transformed_stream = false
    end

    [:to_s, :inspect, :==].each do |method|
      undef_method method if method_defined?(method)
    end

    private

    def method_missing(...)
      transform_stream unless transformed_stream?
      @str.__send__(...)
    end

    def respond_to_missing? sym, *args
      @str.respond_to? sym
    end

    def transform_stream
      @transformed_stream = true

      # We can't do @stream.slice!(@start, @length),
      # as it would invalidate the @starts and @lengths of other Fragment instances.
      @str = @stream[@start, @length].to_s
      @stream[@start, @length] = [nil] * @length
    end

    def transformed_stream?
      @transformed_stream
    end
  end

  class XmlMarkup < ::Builder::XmlMarkup
    attr_accessor :target, :level
  end
end
