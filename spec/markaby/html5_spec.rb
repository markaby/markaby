require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Markaby do
  it "should insert an html5 doctype" do
    document = mab5 { html5 { head { title 'OKay' } } }
    document.should include("<!DOCTYPE html>")
  end

  it "should not have xmlns in html5 html tag" do
    document = mab5 { html5 { head { title 'OKay' } } }
    document.should_not include("xmlns")
  end

  it "should make html5-specific tags" do
    document = mab5 { html5 { tag! :header } }
    document.should include("header")
  end

  it "should accept html5-specific tag as a block" do
    document = mab5 { html5 { header { h1 "Wow" } } }
    document.should include("<header><h1>Wow</h1></header>")
  end

  it "should make html5-specific tags in partials" do
    document = mab5 { header { h1 "Wow" } }
    document.should include("<header><h1>Wow</h1></header>")
  end

  it "should put correct xhtml charset meta" do
    document = mab { xhtml_strict { head { title 'OKay' } } }
    document.should include('<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>')
  end

  it "should put correct html5 charset meta" do
    document = mab5 { html5 { head { title 'OKay' } } }
    document.should include('<meta charset="utf-8">')
  end

  it "should add a class to a html5 tag" do
    document = mab5 { html5 { canvas.big "yo look" } }
    document.should include('<canvas class="big">yo look</canvas>')
  end

  it "should add an id to a html5 tag" do
    document = mab5 { html5 { canvas.only! "yo look" } }
    document.should include('<canvas id="only">yo look</canvas>')
  end

  it "should add a closing slash to self-closing tags in xhtml" do
    document = mab { br }
    document.should include('<br/>')
  end

  it "should not add a closing slash to self-closing tags in html5" do
    document = mab5 { br }
    document.should include('<br>')
  end

  it "should close empty non-self-closing tags in html5" do
    document = mab5 { header }
    document.should include("<header></header>")
  end

  it "should not allow fake attributes" do
    lambda { mab5 { input "something", :fake => "fake" }}.should raise_error(Markaby::InvalidXhtmlError)
  end

  it "should allow new attributes" do
    lambda { mab5 { input "something", :placeholder => "placeholder" }}.should_not raise_error(Markaby::InvalidXhtmlError)
  end
end
