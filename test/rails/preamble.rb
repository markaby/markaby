require 'test/unit'

MARKABY_ROOT    = File.join(File.dirname(__FILE__), "..", "..")
rails_root      = File.join(MARKABY_ROOT, "..", "..", "..")
RAILS_BOOT_FILE = File.join(rails_root, "config", "boot.rb")

RUNNING_RAILS = File.exists?(RAILS_BOOT_FILE) ? true : false

if RUNNING_RAILS
  require RAILS_BOOT_FILE

  Rails::Initializer.run

  require 'action_controller/test_process'
  
  if defined?(Dependencies)
    Dependencies.load_paths.unshift File.dirname(__FILE__)
  end

  $:.unshift MARKABY_ROOT

  require 'init'
  require 'markaby/kernel_method'
else
  warn "Skipping rails specific tests"
end

class Monkey < Struct.new(:name)
  def self.find(*args)
    @@monkeys ||= ['Frank', 'Benny', 'Paul'].map { |name| Monkey.new name }
  end
end