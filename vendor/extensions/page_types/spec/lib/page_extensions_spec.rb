require File.dirname(__FILE__) + "/../spec_helper"

describe Page do

  before do
    @page = Page.new
  end

  it "should list descendants" do
    children = @page.allowed_children
    children.should include(Page)
    children.should include(FileNotFoundPage)
  end
end