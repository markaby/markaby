require 'test/unit'

MARKABY_ROOT    = File.join(File.dirname(__FILE__), "..", "..")
rails_root      = File.join(MARKABY_ROOT, "..", "..", "..")
RAILS_BOOT_FILE = File.join(rails_root, "config", "boot")

RUNNING_RAILS = File.exists?(RAILS_BOOT_FILE) ? true : false

if RUNNING_RAILS
  require RAILS_BOOT_FILE

  Rails::Initializer.run

  require 'action_controller/test_process'

  Dependencies.load_paths.unshift File.dirname(__FILE__)

  $:.unshift markaby_root

  require 'init'

  require 'markaby/kernel_method'

  class Monkey < Struct.new(:name)
    def self.find(*args)
      @@monkeys ||= ['Frank', 'Benny', 'Paul'].map { |name| Monkey.new name }
    end
  end
else
  warn "Skipping rails specific tests"
end
