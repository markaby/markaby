module Markaby
  module Rails
    DEPRECATED_RAILS_VERSION = [
      # "0.10.0",
      # "0.10.1",
      # "0.11.0",
      # "0.11.1",
      # "0.12.0",
      # "0.13.0",
      # "0.13.1",
      # "0.14.1",
      # "0.14.2",
      # "0.14.3",
      # "0.14.4",
      # "0.9.1",
      # "0.9.2",
      # "0.9.3",
      # "0.9.4",
      # "0.9.4.1",
      # "0.9.5",
      # "1.0.0",
      # "1.1.0",
      # "1.1.1",
      # "1.1.2",
      # "1.1.3",
      # "1.1.4",
      # "1.1.5",
      # "1.1.6",
      # "1.2.0",
      # "1.2.1",
      # "1.2.2",
      # "1.2.3",
      # "1.2.4",
      "1.2.5",
      "1.2.6",
    ]

    FULLY_SUPPORTED_RAILS_VERSIONS = [
      # "2.0.0",
      # "2.0.1",
      # "2.0.2",
      # "2.0.3",
      # "2.0.4",
      # "2.0.5",
      "2.1.0",
      "2.1.1",
      "2.1.2",
      "2.2.0",
      "2.2.1",
      "2.2.2",
      "2.2.3",
      # "2.3.0",
      "2.3.1",
      "2.3.2",
      "2.3.2.1",
      "2.3.3",
      "2.3.3.1",
      "2.3.4"
    ]

    SUPPORTED_RAILS_VERSIONS = DEPRECATED_RAILS_VERSION + FULLY_SUPPORTED_RAILS_VERSIONS
  
    class << self
      def load
        check_rails_version

        if deprecated_rails_version?
          require File.dirname(__FILE__) + "/rails/deprecated"
        else
          require File.dirname(__FILE__) + "/rails/current"
        end
      end
      
      def deprecated_rails_version?
        DEPRECATED_RAILS_VERSION.include?(detected_rails_version)
      end

      def check_rails_version
        unless SUPPORTED_RAILS_VERSIONS.include?(detected_rails_version)
          error_message = "Cannot load markaby under rails version #{detected_rails_version}.  "
          error_message << "See Markaby::Rails::SUPPORTED_RAILS_VERSIONS for exactly that, or redefine this constant."
          raise LoadError, error_message
        end
      end

      def rails_version_integer
        detected_rails_version.gsub(".", "").to_i
      end
    
    private

      def detected_rails_version
        if defined?(::Rails)
          ::Rails::VERSION::STRING
        end
      end
    end
  end
end