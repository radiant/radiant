require File.dirname(__FILE__) + '/../spec_helper'

describe MarkdownFilter do
  it "should be named Markdown" do
    MarkdownFilter.filter_name.should == "Markdown"
  end

  it "should filter text according to Markdown rules" do
    MarkdownFilter.filter('**strong**').should =~ %r{<p><strong>strong</strong></p>}
  end

  it "should filter text with quotes into smart quotes" do
    MarkdownFilter.filter("# Radiant's \"filters\" rock!").should =~ %r{<h1>Radiant&(#8217|rsquo);s &(#8220|ldquo);filters&(#8221|rdquo); rock!</h1>}
  end
end

describe "<r:markdown>" do
  dataset :pages
  it "should filter its contents with Markdown" do
    pages(:home).should render("<r:markdown>* item</r:markdown>").matching(%r{<ul>\n(\s+)?<li>item<\/li>\n<\/ul>\n(\n)?})
  end
end