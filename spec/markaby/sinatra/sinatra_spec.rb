unless RUNNING_RAILS
  require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")
  require 'markaby/sinatra'
  require 'rack/test'
  require File.expand_path(File.dirname(__FILE__) + "/app")

  describe "sinatra integration" do
    include Rack::Test::Methods

    def app
      @app ||= Sinatra::Application
    end

    it "should render an empty" do
      get '/empty_action'
      last_response.should be_ok
    end

    it "should render an empty markaby template" do
      get '/markaby_template'
      last_response.should be_ok
      last_response.body.should == ""
    end

    it "should render a template with html in it" do
      get '/simple_html'
      last_response.should be_ok
      last_response.body.should == "<ul><li>hi</li><li>there</li></ul>"
    end

    it "should be able to pass variables" do
      get '/variables'
      last_response.should be_ok
      last_response.body.should == '<p class="name">Scott Taylor</p>'
    end

    it "should be able to pass variables through locals" do
      get '/variables_with_locals'
      last_response.should be_ok
      last_response.body.should == '<p class="name">Scott Taylor</p>'
    end

    it "should have scope to instance variables" do
      get '/scope_instance_variables'
      last_response.should be_ok
      last_response.body.should == '<p class="name">Scott Taylor</p>'
    end

    it "should be able to use named templates" do
      get "/named_template"
      last_response.should be_ok
      last_response.body.should == '<div class="title">Hello World!</div>'
    end

    it "should be able to use a layout with :layout" do
      get '/layout'
      last_response.should be_ok
      last_response.body.should == '<html><div class="title">Hello World!</div></html>'
    end

    it "should be able to access helpers in a template" do
      get '/helpers'
      last_response.should be_ok
      last_response.body.should == "<li>bacon</li>"
    end

    it "should be able to render html5 tags" do
      get '/html5'
      last_response.should be_ok
      last_response.body.should include('<header>')
    end

    it "should not add a slash to self-closing tags" do
      get '/html5'
      last_response.should be_ok
      last_response.body.should include('<br>')
    end
  end
end
