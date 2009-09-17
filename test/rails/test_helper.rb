require 'test/unit'

unless defined?(RUNNING_RAILS)
  MARKABY_ROOT    = File.join(File.dirname(__FILE__), "..", "..")
  rails_root      = File.join(MARKABY_ROOT, "..", "..", "..")
  RAILS_BOOT_FILE = File.join(rails_root, "config", "boot.rb")

  RUNNING_RAILS = File.exists?(RAILS_BOOT_FILE) ? true : false
end

if RUNNING_RAILS
  require RAILS_BOOT_FILE

  Rails::Initializer.run

  require 'action_controller/test_process'

  $:.unshift MARKABY_ROOT

  require 'init'
  require 'markaby/kernel_method'
else
  warn "Skipping rails specific tests"
end
