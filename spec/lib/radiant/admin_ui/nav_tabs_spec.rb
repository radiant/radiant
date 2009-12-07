require File.dirname(__FILE__) + '/../../../spec_helper'

describe Radiant::AdminUI::NavTab do
  before :each do
    @tab = Radiant::AdminUI::NavTab.new("Content")
  end

  it "should have a name" do
    @tab.name.should == "Content"
  end

  it "should be Enumerable" do
    Enumerable.should === @tab
    @tab.should respond_to(:each)
  end

  it "should find contained items by name" do
    subtab = Radiant::AdminUI::NavTab.new("The Pages")
    @tab << subtab
    @tab[:the_pages].should == subtab
    @tab['the pages'].should == subtab
  end

  it "should assign the tab on the sub-item when adding" do
    subtab = Radiant::AdminUI::NavSubItem.new("Pages", "/admin/pages")
    @tab << subtab
    subtab.tab.should == @tab
  end

  describe "inserting sub-items in specific places" do
    before :each do
      @pages    = Radiant::AdminUI::NavSubItem.new("Pages",    "/admin/pages")
      @snippets = Radiant::AdminUI::NavSubItem.new("Snippets", "/admin/snippets")
      @comments = Radiant::AdminUI::NavSubItem.new("Comments", "/admin/comments")
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
    
    it "should not be visible by default" do
      User.all.each {|user| @tab.should_not be_visible(user) }
    end
  end
  
  it "should warn about using the deprecated add method" do
    ActiveSupport::Deprecation.should_receive(:warn)
    @tab.add(:pages, "Pages", "/admin/pages")
    @tab[:pages].name.should == "Pages"
    @tab[:pages].url.should == "/admin/pages"
  end
end

describe Radiant::AdminUI::NavSubItem do
  before :each do
    @tab = Radiant::AdminUI::NavTab.new("Content")
    @subitem = Radiant::AdminUI::NavSubItem.new("Pages", "/admin/pages")
    @tab << @subitem
  end

  it "should have a name" do
    @subitem.name.should == "Pages"
  end

  it "should have a URL" do
    @subitem.url.should == "/admin/pages"
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