require File.dirname(__FILE__) + '/spec_helper'

describe Resourceful::Response, "when first created" do
  before(:each) { @response = Resourceful::Response.new }

  it "should have an empty formats array" do
    @response.formats.should == []
  end
end

describe Resourceful::Response, "with a few formats" do
  before :each do
    @response = Resourceful::Response.new
    @response.html
    @response.js  {'javascript'}
    @response.xml {'xml'}
  end

  it "should store the formats and blocks" do
    @response.formats.should have_any {|f,p| f == :js  && p.call == 'javascript'}
    @response.formats.should have_any {|f,p| f == :xml && p.call == 'xml'}
  end

  it "should give formats without a block an empty block" do
    @response.formats.should have_any {|f,p| f == :html && Proc === p && p.call.nil?}
  end

  it "shouldn't allow duplicate formats" do
    @response.js {'not javascript'}
    @response.formats.should     have_any {|f,p| f == :js && p.call == 'javascript'}
    @response.formats.should_not have_any {|f,p| f == :js && p.call == 'not javascript'}
  end

  it "should keep the formats in sorted order" do
    @response.formats.map(&:first).should == [:html, :js, :xml]
  end
end
