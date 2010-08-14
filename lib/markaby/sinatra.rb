require 'markaby/tilt'

module Sinatra
  class Base
    # sinatra's #render looks for options in Sinatra::Application
    # by asking if it responds_to?(:mab)
    # Unfortunately, if the the mab kernel method is included,
    # Sinatra::Application will respond_to? it.
    set :mab, {}
  end

  module Templates
    def mab(template, options={}, locals={})
      render :mab, template, options, locals
    end
  end
end
