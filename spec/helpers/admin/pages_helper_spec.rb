require File.dirname(__FILE__) + "/../../spec_helper"

class MarkdownPlusFilter
  # dummy filter class
end

describe Admin::PagesHelper do
  dataset :users_and_pages

  before :each do
    @page = mock_model(Page)
    @errors = mock("errors")
    @page.stub!(:errors).and_return(@errors)
    helper.stub!(:image).and_return('')
    helper.stub!(:admin?).and_return(true)
    helper.instance_variable_set(:@page, @page)
  end

  it "should have meta errors if the page has errors on the slug" do
    @errors.should_receive(:[]).with(:slug).and_return("Error")
    helper.meta_errors?.should be_true
  end

  it "should have meta errors if the page has errors on the breadcrumb" do
    @errors.should_receive(:[]).with(:slug).and_return(nil)
    @errors.should_receive(:[]).with(:breadcrumb).and_return("Error")
    helper.meta_errors?.should be_true
  end

  it "should render the tag reference" do
    helper.should_receive(:render).at_least(:once).and_return("Tag Reference")
    helper.tag_reference.should =~ /Tag Reference/
  end

  describe "filter_reference" do
    it "should determine the filter reference from the first part on the current page" do
      helper.instance_variable_set :@page, pages(:home)
      helper.filter.should be_kind_of(TextFilter)
    end
    
    it "should render the filter reference" do
      helper.stub!(:filter).and_return(TextileFilter)
      helper.filter_reference.should == TextileFilter.description
    end
    
    it "should render the filter reference for complex filter names" do
      MarkdownPlusFilter.stub!(:description).and_return("Markdown rocks!")
      helper.stub!(:filter).and_return(MarkdownPlusFilter)
      helper.filter_reference.should == "Markdown rocks!"
    end
  end

  it "should have a default filter name" do
    @page.should_receive(:parts).and_return([])
    helper.default_filter_name.should == ""
  end

  it "should find the homepage" do
    helper.homepage.should == pages(:home)
  end
  
  it "should render javascript for the page editing form" do
    helper.should respond_to(:page_edit_javascripts)
  end

  describe "#child_link_for" do
    it "should disable the menu when there are no allowable children" do
      @page.stub!(:allowed_children).and_return([])
      helper.child_link_for(@page).should match('<span class="action disabled">')
    end

    it "should link to Page#new when there is one allowable child" do
      @page.stub!(:allowed_children).and_return([Page])
      helper.child_link_for(@page).should match(Regexp.escape(new_admin_page_child_path(@page, :page_class => 'Page')))
    end

    it "should show the menu when there are multiple allowable children" do
      @page.stub!(:allowed_children).and_return([Page,FileNotFoundPage])
      helper.child_link_for(@page).should match("#allowed_children_#{@page.id}")
    end
  end

  describe "#children_for" do
    it "should not show virtual pages to designers" do
      helper.stub!(:admin?).and_return(false)
      @page.stub!(:allowed_children).and_return([Page, ArchivePage, FileNotFoundPage])
      helper.children_for(@page).flatten.should_not include(FileNotFoundPage)
    end
  end
  

  describe '#clean_page_description' do
    it "should remove all whitespace (except single spaces) from the given page's description" do
      @page.stub!(:description).and_return(%{
        This is the  description   for the   
            current page!
      })
      helper.clean_page_description(@page).should == 'This is the description for the current page!'
    end
  end

  describe '#child_menu_for' do
    it "should be empty if there are no options" do
      helper.stub!(:children_for).and_return([])
      helper.child_menu_for(@page).should be_nil
    end

    it "should list options if there are any" do
      helper.stub!(:children_for).and_return([Page, FileNotFoundPage])
      @page.stub!(:default_child).and_return(Page)
      menu = helper.child_menu_for(@page)
      menu.should match(/Normal Page/)
    end
  end

end
