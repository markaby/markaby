module Markaby
  class Template
    class << self
      def reset_builder_class!
        self.builder_class = Builder
      end
      
      def builder_class=(builder)
        @builder_class = builder
      end
      
      def builder_class
        @builder_class ||= Builder
      end
    end
    
    attr_accessor :source, :path
    
    def initialize(source)
      @source = source.to_s
    end

    def render(*args)
      output = new_builder(*args)

      path ?
        output.instance_eval(source, path) :
        output.instance_eval(source)
      
      output.to_s
    end
    
  private
  
    def new_builder(*args)
      builder_class.new(*args)
    end
  
    def builder_class
      self.class.builder_class
    end
  end
end
