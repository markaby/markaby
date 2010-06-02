module Markaby
  module Rails
    UNSUPPORTED_RAILS_VERSIONS = [
      "2.0.0",
      "2.0.1",
      "2.0.2",
      "2.0.3",
      "2.0.4",
      "2.0.5",
      "2.1.0",
      "2.1.1",
      "2.1.2",
      "2.3.0"
    ]

    DEPRECATED_RAILS_VERSIONS = [
      "1.2.2",
      "1.2.3",
      "1.2.4",
      "1.2.5",
      "1.2.6"
    ]

    FULLY_SUPPORTED_RAILS_VERSIONS = [
      "2.2.0",
      "2.2.1",
      "2.2.2",
      "2.2.3",
      "2.3.1",
      "2.3.2",
      "2.3.2.1",
      "2.3.3",
      "2.3.3.1",
      "2.3.4"
    ]

    SUPPORTED_RAILS_VERSIONS = DEPRECATED_RAILS_VERSIONS + FULLY_SUPPORTED_RAILS_VERSIONS

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
        DEPRECATED_RAILS_VERSIONS.include?(detected_rails_version)
      end

      def check_rails_version
        if UNSUPPORTED_RAILS_VERSIONS.include?(detected_rails_version)
          error_message = "Cannot load markaby under rails version #{detected_rails_version}.  "
          error_message << "See Markaby::Rails::SUPPORTED_RAILS_VERSIONS for exactly that, or redefine this constant."
          raise LoadError, error_message
        end
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
