require File.join(File.dirname(__FILE__), 'rails', 'preamble')

if RUNNING_RAILS
  if Rails::VERSION::STRING == "2.3.2"
    require "rails_versions/2.3.2"
  else
    require "rails_versions/pre_2.0.2"
  end
end