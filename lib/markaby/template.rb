module Markaby
  class Template

    attr_accessor :source, :path
    
    def initialize(source)
      @source = source.to_s
    end

    def render(*args)
      output = Builder.new(*args)

      if path.nil?
        output.instance_eval source
      else
        output.instance_eval source, path
      end
      
      return output.to_s
    end

  end
end
