$:.unshift File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

require 'markaby'
require 'markaby/rails'

if defined? ActionView::Template and ActionView::Template.respond_to? :register_template_handler
  ActionView::Template
else
  ActionView::Base
end.register_template_handler(:mab, Markaby::Rails::ActionViewTemplateHandler)

ActionController::Base.send :include, Markaby::Rails::ActionControllerHelpers