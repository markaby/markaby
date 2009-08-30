# typical vanilla garlic configuration

garlic do
  # this plugin
  repo "markaby", :path => '.'
  
  # other repos
  repo "rails", :url => "git://github.com/rails/rails"
  
  # target railses
  RAILS_TAREGETS = [
    "v1.2.6",
    "v2.0.0",
    "v2.0.1",
    "v2.0.2",
    # "v2.0.3",
    # "v2.0.4",
    # "v2.0.5",
    # "v2.1.0",
    # "v2.1.1",
    # "v2.1.2",
    # "v2.2.0",
    # "v2.2.1",
    # "v2.2.2",
    # "v2.3.0",
    # "origin/master"
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
