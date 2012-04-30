# You'll need to <tt>require 'markaby/kernel_method'</tt> for this.
module Kernel
  # Shortcut for creating a quick block of Markaby.
  def mab(*args, &block)
    Markaby::Builder.new(*args, &block).to_s
  end
  # Shortcut for creating a quick block of HTML5.
  def mab5(*args, &block)
    Markaby::Builder.set_html5_options!
    mab = Markaby::Builder.new(*args, &block)
    Markaby::Builder.restore_defaults!
    mab.to_s
  end
end
