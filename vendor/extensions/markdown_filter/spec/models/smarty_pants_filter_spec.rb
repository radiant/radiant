require File.dirname(__FILE__) + '/../spec_helper'

describe SmartyPantsFilter do
  it "should be named SmartyPants" do
    SmartyPantsFilter.filter_name.should == "SmartyPants"
  end

  it "should filter text with quotes into smart quotes" do
    SmartyPantsFilter.filter("<h1 class=\"headline\">Radiant's \"filters\" rock!</h1>").should ==
      "<h1 class=\"headline\">Radiant&#8217;s &#8220;filters&#8221; rock!</h1>"
  end
end

describe "<r:smarty_pants>" do
  dataset :pages
  it "should filter its contents with SmartyPants" do
    pages(:home).should render('<r:smarty_pants>"A revolutionary quotation."</r:smarty_pants>').as("&#8220;A revolutionary quotation.&#8221;")
  end
end