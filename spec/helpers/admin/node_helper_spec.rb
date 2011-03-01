require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::NodeHelper do
  dataset :users_and_pages

  before :each do
    @cookies = {}
    @errors = mock("errors")
    helper.stub!(:cookies).and_return(@cookies)
    helper.stub!(:homepage).and_return(nil)
    @page = mock_model(Page)
    @page.stub!(:sheet?).and_return(false) # core extension alters the behavior
    helper.stub!(:image).and_return('')
    helper.stub!(:admin?).and_return(true)
    helper.instance_variable_set(:@page, @page)
  end

  it "should render a sitemap node" do
    helper.should_receive(:render).with(:partial => "node", :locals => {:level => 0, :simple => false, :page => @page}).and_return(@current_node)
    helper.render_node(@page)
    helper.assigns[:current_node] == @page
  end

  it "should show all nodes when on the remove action" do
    assigns[:controller] = @controller
    @controller.should_receive(:action_name).and_return("remove")
    helper.show_all?.should be_true
  end

  it "should not show all nodes automatically when not in the remove action" do
    assigns[:controller] = @controller
    @controller.should_receive(:action_name).and_return("index")
    helper.show_all?.should be_false
  end

  it "should determine which rows to expand" do
    @cookies[:expanded_rows] = "1,2,3"
    helper.expanded_rows.should == [1,2,3]
  end

  it "should determine whether the current node should be expanded" do
    helper.should_receive(:show_all?).and_return(true)
    helper.expanded.should be_true
  end

  it "should determine the left padding for the current level" do
    helper.padding_left(0).should == 9
    helper.padding_left(1).should == 32
    helper.padding_left(2).should == 55
  end

  it "should determine the class of a parent node" do
    assigns[:current_node] = @page
    child = mock("child")
    @page.should_receive(:children).and_return([child])
    helper.should_receive(:expanded).and_return(true)
    helper.children_class.should == " children_visible"
  end

  it "should display an icon for the current node" do
    assigns[:current_node] = @page
    @page.should_receive(:virtual?).and_return(false)
    helper.should_receive(:image).with("page", :class => "icon", :alt => '', :title => '')
    helper.icon
  end
  
  it "should display the virtual icon if the current node is virtual" do
    assigns[:current_node] = @page
    @page.should_receive(:virtual?).and_return(true)
    helper.should_receive(:image).with("virtual_page", :class => "icon", :alt => '', :title => '')
    helper.icon
  end

  it "should render the title of the current node" do
    assigns[:current_node] = @page
    @page.should_receive(:title).and_return("Title")
    helper.node_title.should == %{<span class="title">Title</span>}
  end

  it "should render the title of the current node with HTML entities escaped" do
    assigns[:current_node] = @page
    @page.should_receive(:title).and_return("Ham & Cheese")
    helper.node_title.should == %{<span class="title">Ham &amp; Cheese</span>}
  end

  it "should render the page type if it's not Page" do
    assigns[:current_node] = @page
    @class = mock("Class")
    @page.should_receive(:class).and_return(@class)
    @class.should_receive(:display_name).and_return("Special")
    helper.page_type.should ==  %{<span class="info">(Special)</span>}
  end

  it "should not render the page type if it's Page" do
    assigns[:current_node] = @page
    @page.should_receive(:class).and_return(Page)
    helper.page_type.should ==  %{}
  end

  it "should render the busy spinner" do
    assigns[:current_node] = @page
    @page.should_receive(:id).and_return(1)
    helper.should_receive(:image).with('spinner.gif',
            :class => 'busy', :id => "busy_1",
            :alt => "",  :title => "",
            :style => 'display: none;')
    helper.spinner
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