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

  it "should reject pages that don't belong in the menu" do
    FileNotFoundPage.in_menu false
    @page.allowed_children.should_not include(FileNotFoundPage)
  end
end