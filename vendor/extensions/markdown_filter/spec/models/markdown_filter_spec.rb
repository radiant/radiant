require File.dirname(__FILE__) + '/../spec_helper'

describe MarkdownFilter do
  it "should be named Markdown" do
    MarkdownFilter.filter_name.should == "Markdown"
  end

  it "should filter text according to Markdown rules" do
    MarkdownFilter.filter('**strong**').should == '<p><strong>strong</strong></p>'
  end

  it "should filter text with quotes into smart quotes" do
    MarkdownFilter.filter("# Radiant's \"filters\" rock!").should == "<h1>Radiant&#8217;s &#8220;filters&#8221; rock!</h1>"
  end
end

describe "<r:markdown>" do
  dataset :pages
  it "should filter its contents with Markdown" do
    pages(:home).should render("<r:markdown>* item </r:markdown>").as("<ul>\n<li>item </li>\n</ul>")
  end
end