require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Markaby do
  it "inserts an html5 doctype" do
    document = mab { html5 { head { title 'OKay' } } }
    document.should include("<!DOCTYPE html>")
  end

  it "should not have xmlns in html5 html tag" do
    document = mab { html5 { head { title 'OKay' } } }
    document.should_not include("xmlns")
  end

  it "should make a html5-specific tag" do
    document = mab { html5 { tag! :header } }
    document.should include("header")
  end

  it "should accept a html5-specific tag as a block" do
    document = mab { html5 { header { h1 "Wow" } } }
    document.should include("<header><h1>Wow</h1></header>")
  end

  it "should put correct xhtml charset meta" do
    document = mab { xhtml_strict { head { title 'OKay' } } }
    document.should include('<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>')
  end

  it "should put correct html5 charset meta" do
    document = mab { html5 { head { title 'OKay' } } }
    document.should include('<meta charset="utf-8"/>')
# TODO: sort out the differences in self-closing in HTML5, i.e.
#    document.should include('<meta charset="utf-8">')
  end

  it "should work fine with a class" do
    document = mab { html5 { canvas.big "yo look" } }
    document.should include('<canvas class="big">yo look</canvas>')
  end

  it "should work fine with an id" do
    document = mab { html5 { canvas.only! "yo look" } }
    document.should include('<canvas id="only">yo look</canvas>')
  end

end
