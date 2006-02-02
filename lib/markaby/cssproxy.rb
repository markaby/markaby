module Markaby
  # Class used by Markaby::Builder to store element options.  Methods called
  # against the CssProxy object are added as element classes or IDs.
  #
  # See the README for examples.
  class CssProxy

    # Creates a CssProxy object.  The +opts+ and +block+ passed in are
    # stored until the element is created by Builder.tag!
    def initialize(opts = {}, &blk)
      @opts = opts
      @blk = blk
    end
  
    # Adds attributes to an element.  Bang methods set the :id attribute.
    # Other methods add to the :class attribute.  If a block is supplied,
    # it is executed with a merged hash (@opts + args).
    def method_missing(id_or_class, *args, &blk)
      idc = id_or_class.to_s
      case idc
      when /!$/
        @opts[:id] = $`
      else 
        @opts[:class] = "#{@opts[:class]} #{idc}".strip
      end
      if args.empty? and blk.nil?
        self
      else
        if args.last.respond_to? :to_hash
          @opts.merge!(args.pop.to_hash)
        end
        args.push @opts
        @blk.call(args, blk)
      end
    end
  end
end
