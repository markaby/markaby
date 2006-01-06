$:.unshift File.expand_path(File.join(File.dirname(__FILE__), 'lib'))

require 'markaby'
require 'markaby/view'

ActionView::Base::register_template_handler :mab, Markaby::View
