# typical vanilla garlic configuration

garlic do
  # this plugin
  repo "markaby", :path => '.'
  
  # other repos
  repo "rails", :url => "git://github.com/rails/rails"

  # target railses
  RAILS_TAREGETS = [
    # "v0.10.0",
    # "v0.10.1",
    # "v0.11.0",
    # "v0.11.1",
    # "v0.12.0",
    # "v0.13.0",
    # "v0.13.1",
    # "v0.14.1",
    # "v0.14.2",
    # "v0.14.3",
    # "v0.14.4",
    # "v0.9.1",
    # "v0.9.2",
    # "v0.9.3",
    # "v0.9.4",
    # "v0.9.4.1",
    # "v0.9.5",
    # "v1.0.0",
    # "v1.1.0",
    # "v1.1.0_RC1",
    # "v1.1.1",
    # "v1.1.2",
    # "v1.1.3",
    # "v1.1.4",
    # "v1.1.5",
    # "v1.1.6",
    # "v1.2.0",
    # "v1.2.0_RC1",
    # "v1.2.0_RC2",
    # "v1.2.1",
    # "v1.2.2",
    # "v1.2.3",
    # "v1.2.4",
    # "v1.2.5",
    "v1.2.6",
    # "v2.0.0",
    # "v2.0.0_PR",
    # "v2.0.0_RC1",
    # "v2.0.0_RC2",
    # "v2.0.1",
    # "v2.0.2",
    # "v2.0.3",
    # "v2.0.4",
    # "v2.0.5",
    "v2.1.0",
    "v2.1.0_RC1",
    "v2.1.1",
    "v2.1.2",
    "v2.2.0",
    "v2.2.1",
    "v2.2.2",
    "v2.2.3",
    # "v2.3.0",
    "v2.3.1",
    "v2.3.2",
    "v2.3.2.1",
    "v2.3.3",
    "v2.3.3.1",
    "v2.3.4"
  ]

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
