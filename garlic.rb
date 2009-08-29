# typical vanilla garlic configuration

garlic do
  # this plugin
  repo "markaby", :path => '.'
  
  # other repos
  repo "rails", :url => "git://github.com/rails/rails"
  
  # target railses
  ['origin/master', 'origin/2-2-stable', 'origin/2-1-stable', 'origin/2-0-stable'].each do |rails|
    
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
