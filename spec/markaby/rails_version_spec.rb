require File.join(File.dirname(__FILE__), 'rails', 'spec_helper')

unless RUNNING_RAILS
  require File.join(File.dirname(__FILE__), '..', 'spec_helper')
  
  describe "when rails is loaded, but is not a supported version" do
    module MockRails
      module VERSION
        STRING = "0.0.0"
      end
    end
    
    def install_mock_rails
      Object.const_set(:Rails, MockRails)
    end
    
    def remove_mock_rails
      Object.class_eval do
        remove_const(:Rails)
      end
    end
    
    before do
      install_mock_rails
    end
    
    after do
      remove_mock_rails
    end
    
    it "should raise" do
      lambda {
        ::Markaby::Rails.load
      }.should raise_error(LoadError, "Cannot load markaby under rails version 0.0.0.  See Markaby::Rails::SUPPORTED_RAILS_VERSIONS for exactly that, or redefine this constant.")
    end
  end
end
