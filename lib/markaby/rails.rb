if defined?(Rails)
  module Markaby
    module Rails
      DETECTED_RAILS_VERSION = ::Rails::VERSION::STRING.gsub(".", "").to_i
    end
  end
  
  if Markaby::Rails::DETECTED_RAILS_VERSION == 126
    require File.dirname(__FILE__) + "/rails/deprecated"
  else
    require File.dirname(__FILE__) + "/rails/current"
  end
end