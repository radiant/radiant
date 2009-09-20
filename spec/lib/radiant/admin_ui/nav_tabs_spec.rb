require File.dirname(__FILE__) + '/../../../spec_helper'

describe Radiant::AdminUI::NavTab do
  before :each do
    @tab = Radiant::AdminUI::NavTab.new(:content, "Content")
  end

  it "should have a name" do
    @tab.name.should == :content
  end

  it "should have a proper name" do
    @tab.proper_name.should == "Content"
  end
  
  it "should set the proper name according to the name if no proper_name is given" do
    @tab = Radiant::AdminUI::NavTab.new(:a_new_tab)
    @tab.proper_name.should == "A New Tab"
  end

  it "should be Enumerable" do
    Enumerable.should === @tab
    @tab.should respond_to(:each)
  end

  it "should find contained items by name" do
    subtab = Radiant::AdminUI::NavTab.new(:pages, "Pages")
    @tab << subtab
    @tab[:pages].should == subtab
    @tab['pages'].should == subtab
  end

  it "should assign the tab on the sub-item when adding" do
    subtab = Radiant::AdminUI::NavSubItem.new("/admin/pages")
    @tab << subtab
    subtab.tab.should == @tab
  end

  describe "inserting sub-items in specific places" do
    before :each do
      @pages    = Radiant::AdminUI::NavSubItem.new("/admin/pages")
      @snippets = Radiant::AdminUI::NavSubItem.new("/admin/snippets")
      @comments = Radiant::AdminUI::NavSubItem.new("/admin/comments")
      @tab << @pages
      @tab << @snippets
    end

    it "should insert at the end by default" do
      @tab << @comments
      @tab.last.should == @comments
    end
    
    it "should insert before the specified sub-item" do
      @tab.add(@comments, :before => :snippets)
      @tab[1].should == @comments
    end
    
    it "should insert after the specified sub-item" do
      @tab.add(@comments, :after => :pages)
      @tab[1].should == @comments
    end
    
    it "should raise an error if a sub-item of the same name already exists" do
      @tab << @comments
      lambda { @tab << @comments.dup }.should raise_error(Radiant::AdminUI::DuplicateTabNameError)
    end
  end

  describe "visibility" do
    dataset :users
    
    it "should not be visible if it is empty" do
      @tab.should_not be_visible(users(:admin))
    end
    
    it "should be visible if any of the sub items are visible to the current user" do
      @subitem = Radiant::AdminUI::NavSubItem.new("/admin/pages")
      @tab << @subitem
      @tab.should be_visible(users(:admin))
    end
    
    it "should not be visible if any of the sub items are not visible to the current user" do
      @subitem = Radiant::AdminUI::NavSubItem.new("/admin/users")
      @tab << @subitem
      @tab.should_not be_visible(users(:existing))
    end
  end
  
  it "should warn about using the deprecated add method" do
    ActiveSupport::Deprecation.should_receive(:warn)
    @tab.add("/admin/pages")
    @tab[:pages].proper_name.should == "Pages"
    @tab[:pages].url.should == "/admin/pages"
  end
end

describe Radiant::AdminUI::NavSubItem do
  before :each do
    @tab = Radiant::AdminUI::NavTab.new(:content)
    @subitem = Radiant::AdminUI::NavSubItem.new("/admin/pages")
    @tab << @subitem
  end

  it "should have a name" do
    @subitem.name.should == :pages
  end

  it "should have a proper name" do
    @subitem.proper_name.should == "Pages"
  end

  it "should have a URL" do
    @subitem.url.should == "/admin/pages"
  end
  
  it "should create it's name based on the given URL" do
    @subitem = Radiant::AdminUI::NavSubItem.new('/admin/all_around/town')
    @subitem.name.should == :all_around_town
  end
  
  it "should parameterize and underscore a generated name" do
    @subitem = Radiant::AdminUI::NavSubItem.new('/admin/things/to-do')
    @subitem.name.should == :things_to_do
  end
  
  it "should generate a titilized proper name when given no proper_name" do
    @subitem = Radiant::AdminUI::NavSubItem.new('/admin/things/to-do')
    @subitem.proper_name.should == 'Things To Do'
  end
  
  describe "generating a relative url" do
    it "should return the original url when no relative_url_root is set" do
      @subitem.relative_url.should == "/admin/pages"
    end
    
    it "should make the url relative to the relative_url_root when set" do
      ActionController::Base.relative_url_root = '/radiant'
      @subitem.relative_url.should == "/radiant/admin/pages"
    end
    
    after :each do
      ActionController::Base.relative_url_root = nil
    end
  end
  
  it "should have a tab accessor" do
    @subitem.should respond_to(:tab)
    @subitem.should respond_to(:tab=)
    @subitem.tab.should == @tab
  end
  
  describe "visibility" do
    dataset :users
    before :each do
      @controller = Admin::UsersController.new
      Admin::UsersController.stub!(:new).and_return(@controller)
    end
    
    it "should check the visibility against the controller permissions" do
      User.all.each {|user| @subitem.should be_visible(user) }
    end
    
    describe "when the controller limits access to the action" do
      before :each do
        @subitem.url.sub!('pages', 'users')
      end
      
      it "should not be visible if the user lacks access" do
        @controller.stub!(:current_user).and_return(users(:existing))
        @subitem.should_not be_visible(users(:existing))
      end
      
      it "should be visible if the user has access" do
        @controller.stub!(:current_user).and_return(users(:admin))
        @subitem.should be_visible(users(:admin))
      end
    end
  end
end