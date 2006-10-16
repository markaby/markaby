module Kernel
  def mab(*args, &block) # :nodoc:
    Markaby::Builder.new(*args, &block).to_s
  end
end