set :views, lambda { File.join(File.dirname(__FILE__), "views") }

get '/empty_action' do
  "hi there"
end

get '/markaby_template' do
  mab :markaby_template
end

get '/simple_html' do
  mab :simple_html
end

get '/variables' do
  mab :variables, {}, :name => "Scott Taylor"
end

get '/variables_with_locals' do
  mab :variables, :locals => { :name => "Scott Taylor" }
end

get '/scope_instance_variables' do
  @name = "Scott Taylor"
  mab :variables
end

template :layout_index do
  'div.title "Hello World!"'
end

get "/named_template" do
  mab :layout_index
end

get "/layout" do
  @display_layout = true
  mab :layout_index
end

helpers do
  def chunky
    "bacon"
  end
end

get "/helpers" do
  mab :helpers
end

get "/html5" do
  Markaby::Builder.set_html5_options!
  mab :html5
end
