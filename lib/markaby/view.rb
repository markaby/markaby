module Markaby
  class View
    def initialize(action_view)
      @action_view = action_view
    end
    def render(template, local_assigns = {})
      Template.new(template).render(@action_view.assigns.merge(local_assigns), @action_view)
    end
  end
end
