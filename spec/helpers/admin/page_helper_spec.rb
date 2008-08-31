require File.dirname(__FILE__) + "/../../spec_helper"

class MarkdownPlusFilter
  # dummy filter class
end

describe Admin::PageHelper do
  scenario :users_and_pages

  before :each do
    @page = mock_model(Page)
    @errors = mock("errors")
    @page.stub!(:errors).and_return(@errors)
  end

  it "should have meta errors if the page has errors on the slug" do
    @errors.should_receive(:[]).with(:slug).and_return("Error")
    meta_errors?.should be_true
  end

  it "should have meta errors if the page has errors on the breadcrumb" do
    @errors.should_receive(:[]).with(:slug).and_return(nil)
    @errors.should_receive(:[]).with(:breadcrumb).and_return("Error")
    meta_errors?.should be_true
  end

  it "should render the tag reference" do
    should_receive(:render).at_least(:once).and_return("Tag Reference")
    tag_reference("Page").should =~ /Tag Reference/
  end

  describe "#filter_reference" do
    it "should render the filter reference" do
      filter_reference("Textile").should == TextileFilter.description
      filter_reference("").should == "There is no filter on the current page part."
    end
    
    it "should render the filter reference for complex filter names" do
      MarkdownPlusFilter.stub!(:description).and_return("Markdown rocks!")
      filter_reference("Markdown Plus").should == "Markdown rocks!"
    end
  end

  it "should have a default filter name" do
    @page.should_receive(:parts).and_return([])
    default_filter_name.should == ""
  end

  it "should find the homepage" do
    homepage.should == pages(:home)
  end
  
  it "should render javascript for the page editing form" do
    self.should respond_to(:page_edit_javascripts)
  end
end