require 'markaby/tags'
require 'markaby/builder_tags'

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
      :indent                 => 0,
      :auto_validation        => true,
    }

    HTML5_OPTIONS   = HTML5.default_options.dup
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
        self.instance_variable_set("@#{k}".to_sym, v)
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

      if helper
        helper.instance_variables.each do |iv|
          instance_variable_set(iv, helper.instance_variable_get(iv))
        end
      end

      @builder = XmlMarkup.new(:indent => @indent, :target => @streams.last)

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
      ele_id = nil

      # TODO: Move this logic to the tagset so that the tagset itself can validate + raise when invalid
      if @auto_validation && @tagset
        if !@tagset.tagset.has_key?(tag)
          raise InvalidXhtmlError, "no element `#{tag}' for #{tagset.doctype}"
        elsif args.last.respond_to?(:to_hash)
          attrs = args.last.to_hash

          if @tagset.forms.include?(tag) && attrs[:id]
            attrs[:name] ||= attrs[:id]
          end

          attrs.each do |k, v|
            atname = k.to_s.downcase.intern

            unless k =~ /:/ or @tagset.tagset[tag].include?(atname) or (@tagset == Markaby::HTML5 && atname.to_s =~ /^data-/)
              raise InvalidXhtmlError, "no attribute `#{k}' on #{tag} elements"
            end

            if atname == :id
              ele_id = v.to_s

              if @used_ids.has_key? ele_id
                raise InvalidXhtmlError, "id `#{ele_id}' already used (id's must be unique)."
              end
            end

            if AttrsBoolean.include? atname
              if v
                attrs[k] = atname.to_s
              else
                attrs.delete k
              end
            end
          end
        end
      end

      if block
        str = capture(&block)
        block = proc { text(str) }
      end

      f = fragment { @builder.tag!(tag, *args, &block) }
      @used_ids[ele_id] = f if ele_id
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
    # * If a tagset is found, though, +NoMethodError+ is raised.
    #
    # method_missing used to be the lynchpin in Markaby, but it's no longer used to handle
    # HTML tags.  See html_tag for that.
    def method_missing(sym, *args, &block)
      if @_helper.respond_to?(sym, true)
        @_helper.send(sym, *args, &block)
      elsif @assigns.has_key?(sym)
        @assigns[sym]
      elsif @assigns.has_key?(stringy_key = sym.to_s)
        # Rails' ActionView assigns hash has string keys for
        # instance variables that are defined in the controller.
        @assigns[stringy_key]
      elsif instance_variables_for(self).include?(ivar = "@#{sym}".to_sym)
        instance_variable_get(ivar)
      elsif @_helper && instance_variables_for(@_helper).include?(ivar)
        @_helper.instance_variable_get(ivar)
      elsif instance_methods_for(::Builder::XmlMarkup).include?(sym)
        @builder.__send__(sym, *args, &block)
      elsif !@tagset
        tag!(sym, *args, &block)
      else
        super
      end
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

    def method_missing(*args, &block)
      transform_stream unless transformed_stream?
      @str.__send__(*args, &block)
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
