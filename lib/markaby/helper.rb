module Markaby
  module ActionControllerHelper
    def render_markaby(options = {}, &block)
      render options.merge({
        :text => Builder.new(nil, self, &block).to_s
      })
    end
  end
end