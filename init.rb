$:.unshift File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

require 'markaby'
require 'markaby/view'
require 'markaby/helper'

ActionView::Base::register_template_handler :mab, Markaby::View

ActionController::Base.send :include, Markaby::ActionControllerHelper
