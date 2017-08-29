require 'spec_helper'
require 'radiant/admin_ui'

describe Radiant::AdminUI::NavTab do
  before :each do
    @tab = Radiant::AdminUI::NavTab.new("Content")
  end

  it "should have a name" do
    expect(@tab.name).to eq("Content")
  end

  it "should be Enumerable" do
    expect(Enumerable).to be === @tab
    expect(@tab).to respond_to(:each)
  end

  it "should find contained items by name" do
    subtab = Radiant::AdminUI::NavTab.new("The Pages")
    @tab << subtab
    expect(@tab[:the_pages]).to eq(subtab)
    expect(@tab['the pages']).to eq(subtab)
  end

  it "should assign the tab on the sub-item when adding" do
    subtab = Radiant::AdminUI::NavSubItem.new("Pages", "/admin/pages")
    @tab << subtab
    expect(subtab.tab).to eq(@tab)
  end

  describe "inserting sub-items in specific places" do
    before :each do
      @pages    = Radiant::AdminUI::NavSubItem.new("Pages",    "/admin/pages")
      @things   = Radiant::AdminUI::NavSubItem.new("Things",   "/admin/things")
      @comments = Radiant::AdminUI::NavSubItem.new("Comments", "/admin/comments")
      @tab << @pages
      @tab << @things
    end

    it "should insert at the end by default" do
      @tab << @comments
      expect(@tab.last).to eq(@comments)
    end

    it "should insert before the specified sub-item" do
      @tab.add(@comments, before: :things)
      expect(@tab[1]).to eq(@comments)
    end

    it "should insert after the specified sub-item" do
      @tab.add(@comments, after: :pages)
      expect(@tab[1]).to eq(@comments)
    end

    it "should raise an error if a sub-item of the same name already exists" do
      @tab << @comments
      expect { @tab << @comments.dup }.to raise_error(Radiant::AdminUI::DuplicateTabNameError)
    end
  end

  describe "visibility" do
    #dataset :users

    it "should not be visible by default" do
      User.all.each {|user| expect(@tab).not_to be_visible(user) }
    end
  end

  it "should warn about using the deprecated add method" do
    expect(ActiveSupport::Deprecation).to receive(:warn)
    @tab.add("Pages", "/admin/pages")
    expect(@tab['Pages'].name).to eq("Pages")
    expect(@tab['Pages'].url).to eq("/admin/pages")
  end
end

describe Radiant::AdminUI::NavSubItem do
  before :each do
    @tab = Radiant::AdminUI::NavTab.new("Content")
    @subitem = Radiant::AdminUI::NavSubItem.new("Pages", "/admin/pages")
    @tab << @subitem
  end

  it "should have a name" do
    expect(@subitem.name).to eq("Pages")
  end

  it "should have a URL" do
    expect(@subitem.url).to eq("/admin/pages")
  end

  describe "generating a relative url" do
    it "should return the original url when no relative_url_root is set" do
      expect(@subitem.relative_url).to eq("/admin/pages")
    end

    it "should make the url relative to the relative_url_root when set" do
      ActionController::Base.relative_url_root = '/radiant'
      expect(@subitem.relative_url).to eq("/radiant/admin/pages")
    end

    after :each do
      ActionController::Base.relative_url_root = nil
    end
  end

  it "should have a tab accessor" do
    expect(@subitem).to respond_to(:tab)
    expect(@subitem).to respond_to(:tab=)
    expect(@subitem.tab).to eq(@tab)
  end

  describe "visibility" do
    let(:admin){ FactoryGirl.build(:user, admin: true) }
    let(:existing){ FactoryGirl.build(:user) }

    before :each do
      @controller = Radiant::Admin::UsersController.new
      allow(Radiant::Admin::UsersController).to receive(:new).and_return(@controller)
    end

    it "should check the visibility against the controller permissions" do
      User.all.each {|user| expect(@subitem).to be_visible(user) }
    end

    describe "when the controller limits access to the action" do
      before :each do
        @subitem.url.sub!('pages', 'users')
      end

      it "should not be visible if the user lacks access" do
        allow(@controller).to receive(:current_user).and_return(existing)
        expect(@subitem).not_to be_visible(existing)
      end

      it "should be visible if the user has access" do
        allow(@controller).to receive(:current_user).and_return(admin)
        expect(@subitem).to be_visible(admin)
      end
    end
  end
end