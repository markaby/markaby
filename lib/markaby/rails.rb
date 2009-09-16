if defined?(Rails)
  if Rails::VERSION::STRING == "2.3.2"
    require File.dirname(__FILE__) + "/rails/2.3.2.rb"
  else
    require "markaby/rails/pre_2_0_2"
  end
end