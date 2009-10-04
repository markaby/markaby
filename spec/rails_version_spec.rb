require File.join(File.dirname(__FILE__), 'rails', 'spec_helper')

module Markaby
  describe "rails version" do
    if RUNNING_RAILS
      it "should support the current rails version" do
        Markaby::Rails::SUPPORTED_RAILS_VERSIONS.should include(::Rails::VERSION::STRING)
      end
    end
  end
end