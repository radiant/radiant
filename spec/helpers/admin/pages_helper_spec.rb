require File.dirname(__FILE__) + "/../../spec_helper"

class MarkdownPlusFilter
  # dummy filter class
end

describe Radiant::Admin::PagesHelper do
  #dataset :users_and_pages

  before :each do
    @page = mock_model(Page)
    @errors = double("errors")
    allow(@page).to receive(:errors).and_return(@errors)
    allow(helper).to receive(:image).and_return('')
    allow(helper).to receive(:admin?).and_return(true)
    helper.instance_variable_set(:@page, @page)
  end

  it "should have meta errors if the page has errors on the slug" do
    expect(@errors).to receive(:[]).with(:slug).and_return("Error")
    expect(helper.meta_errors?).to be true
  end

  it "should have meta errors if the page has errors on the breadcrumb" do
    expect(@errors).to receive(:[]).with(:slug).and_return(nil)
    expect(@errors).to receive(:[]).with(:breadcrumb).and_return("Error")
    expect(helper.meta_errors?).to be true
  end

  it "should render the tag reference" do
    expect(helper).to receive(:render).at_least(:once).and_return("Tag Reference")
    expect(helper.tag_reference).to match(/Tag Reference/)
  end

  describe "filter_reference" do
    it "should determine the filter reference from the first part on the current page" do
      helper.instance_variable_set :@page, pages(:home)
      expect(helper.filter).to be_kind_of(TextFilter)
    end

    it "should render the filter reference for complex filter names" do
      allow(MarkdownPlusFilter).to receive(:description).and_return("Markdown rocks!")
      allow(helper).to receive(:filter).and_return(MarkdownPlusFilter)
      expect(helper.filter_reference).to eq("Markdown rocks!")
    end
  end

  it "should have a default filter name" do
    expect(@page).to receive(:parts).and_return([])
    expect(helper.default_filter_name).to eq("")
  end

  it "should find the homepage" do
    expect(helper.homepage).to eq(pages(:home))
  end

  it "should render javascript for the page editing form" do
    expect(helper).to respond_to(:page_edit_javascripts)
  end

end
