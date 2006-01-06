module Markaby
  class CssProxy

    def initialize(opts = {}, &blk)
      @opts = opts
      @blk = blk
    end
  
    def method_missing(id_or_class, *args, &blk)
      idc = id_or_class.to_s
      case idc
      when /!$/
        @opts[:id] = $`
      else 
        @opts[:class] ||= ""
        @opts[:class] += "#{idc} "
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
