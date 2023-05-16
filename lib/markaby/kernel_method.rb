# You'll need to <tt>require 'markaby/kernel_method'</tt> for this.
require "markaby"

module Kernel
  # Shortcut for creating a quick block of Markaby.
  def mab(...)
    Markaby::Builder.new(...).to_s
  end
end
