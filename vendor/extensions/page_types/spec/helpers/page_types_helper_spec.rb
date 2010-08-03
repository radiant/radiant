require File.dirname(__FILE__) + "/../spec_helper"

describe PageTypesExtension::PageTypesHelper do
  dataset :home_page
  attr_reader :current_user
  include ApplicationHelper
  include PageTypesExtension::PageTypesHelper

  before do
    @page = pages(:home)
    @current_user = stub(:admin? => true)
  end

  describe "#child_link" do
    it "should disable a link with no options" do
      @page.stub!(:allowed_children).and_return([])
      child_link_for(@page).should match('<span class="action disabled">')
    end

    it "should link to Page#new with a single option" do
      @page.stub!(:allowed_children).and_return([Page])
      child_link_for(@page).should match(Regexp.escape(new_admin_page_child_path(@page, :page_class => 'Page')))
    end

    it "should link to div with multiple options" do
      @page.stub!(:allowed_children).and_return([Page,FileNotFoundPage])
      child_link_for(@page).should match("#allowed_children_#{page_id(:home)}")
    end
  end

  describe "#children_for" do
    it "should not show virtual pages to designers" do
      @page.stub!(:allowed_children).and_return([Page, ArchivePage, FileNotFoundPage])
      current_user.stub!(:admin?).and_return(false)
      children_for(@page).flatten.should_not include(FileNotFoundPage)
    end
  end
end