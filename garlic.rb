require File.expand_path(File.dirname(__FILE__) + "/lib/markaby/rails")

garlic do
  # this plugin
  repo "markaby", :path => '.'

  # other repos
  repo "rails", :url => "git://github.com/rails/rails"

  # target railses
  RAILS_TAREGETS = Markaby::Rails::SUPPORTED_RAILS_VERSIONS.map do |version|
    "v#{version}"
  end

  RAILS_TAREGETS.each do |rails|
    # declare how to prepare, and run each CI target
    target "Rails: #{rails}", :tree_ish => rails do
      prepare do
        plugin "markaby", :clone => true # so we can work in targets
      end

      run do
        cd "vendor/plugins/markaby" do
          sh "rake"
        end
      end
    end
  end
end
