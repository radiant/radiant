require 'spec'
require 'spec/autorun'
require 'ostruct'
$: << File.expand_path(__FILE__ + '../../../../app/models')
require 'menu_renderer'
require 'active_support/core_ext'
require 'active_support/core_ext/string/inflections'
require 'action_view'

unless defined?(Page)
  class Page
    class << self
      def default_child
        Page
      end
      alias_method :description, :to_s
      alias_method :name, :to_s
    end
    def default_child
      self.class.default_child
    end
    def description
      self.class.description
    end
    def class_name
      self.class.to_s
    end
  end
end
unless defined?(I18n)
  class I18n; end
end
class AlternatePage < Page; end
class SpecialChildPage < Page; end
class SuperSpecialChildPage < Page; end
module SpecialTestMenuRenderer; end

describe MenuRenderer do

  let(:view){
    view = OpenStruct.new
    view.extend ActionView::Helpers::TagHelper, ActionView::Helpers::UrlHelper
    view
  }
  let(:alternate_page){
    alternate_page = AlternatePage.new
    alternate_page.extend MenuRenderer
    alternate_page.stub!(:view).and_return(view)
    alternate_page
  }
  let(:special_page){
    special_page_class = SpecialChildPage
    special_page = OpenStruct.new(:class_name => 'SpecialTestPage', :view => view, :class => special_page_class)
    special_page.extend MenuRenderer
    special_page
  }

  context 'excluding classes from child list' do
    it 'adds to a collection of excluded classes' do
      lambda{ MenuRenderer.exclude 'Page' }.should_not raise_error
    end
    it 'should be retrievable by the extended object' do
      MenuRenderer.exclude 'Page', 'SpecialPage'
      page = Object.new
      page.extend MenuRenderer
      page.excluded_class_names.should include('Page')
      page.excluded_class_names.should include('SpecialPage')
    end
  end

  it 'should allow you to set a view object for accessing helpers' do
    page = Object.new
    page.extend MenuRenderer
    view = Object.new
    page.view = view
    page.view.should == view
  end

  describe '#additional_menu_features?' do
    it 'should be true if there is another renderer module' do
      special_page.additional_menu_features?.should be_true
    end
    it 'should not be true if there is no additional renderer module' do
      special_page.class_name = 'MoreSpecialTestPage'
      special_page.additional_menu_features?.should_not be_true
    end
  end

  describe '#menu_renderer_module_name' do
    it 'should return the conventional name of an additonal module' do
      special_page.menu_renderer_module_name.should == 'SpecialTestMenuRenderer'
    end
    it 'should return the module name if the class_name is nil' do
      special_page.stub!(:class_name).and_return(nil)
      special_page.menu_renderer_module_name.should == 'MenuRenderer'
    end
  end

  describe '#menu_renderer_modules' do
    it 'should return a collection of modules for additional extension' do
      special_page.menu_renderer_modules.should == [SpecialTestMenuRenderer]
    end
  end

  describe '#allowed_child_classes' do
    it 'should return a collection of classes to be used for child pages' do
      special_page.allowed_children_cache = 'Page,SpecialChildPage'
      special_page.allowed_child_classes.should == [Page, SpecialChildPage]
    end
    it 'should exclude any MenuRenderer excluded classes' do
      special_page.should_receive(:excluded_class_names).and_return ['SpecialChildPage']
      special_page.allowed_children_cache = 'Page,SpecialChildPage'
      special_page.allowed_child_classes.should == [Page]
    end
    it 'should not error when the allowed_children_cache is nil' do
      special_page.allowed_children_cache = nil
      lambda{
        special_page.allowed_child_classes
      }.should_not raise_error
    end
    it 'should not raise error when the allowed_children_cache is unable to find a class' do
      special_page.allowed_children_cache = 'Page, SpecialChildPa' #the last class name is truncated by limit in database
      lambda{
        special_page.allowed_child_classes
      }.should_not raise_error
    end
  end

  describe '#default_child_item' do
    before do
      @link_text = 'New Page Link'
      I18n.should_receive(:t).and_return(@link_text)
      view.stub!(:new_admin_page_child_path).and_return'/pages/new'
      special_page.default_child = SpecialChildPage
    end
    it 'should return a menu item for the default child type' do
      special_page.default_child_item.should match(/<li><a href="[^"]*".*>#{@link_text}<\/a><\/li>/)
    end
    it 'should have a title from the child class description' do
      title_text = 'A very special child...'
      SpecialChildPage.should_receive(:description).and_return(title_text)
      special_page.default_child_item.should match(/<a .*title="#{title_text}">/)
    end
  end

  describe '#separator_item' do
    before do
      special_page.default_child = SpecialChildPage
    end
    it 'should return a menu item with no content' do
      special_page.separator_item.should match(/<li[^>]*><\/li>/)
    end
    it 'should have a CSS class set for styling' do
      special_page.separator_item.should match(/class="separator"/)
    end
  end

  describe '#child_items' do
    before do
      alternate_page.stub!(:allowed_child_classes).and_return [Page, SpecialChildPage, SuperSpecialChildPage]
      AlternatePage.stub!(:default_child).and_return(SpecialChildPage)
      view.stub!(:new_admin_page_child_path).and_return'/pages/new'
    end
    it 'should return a menu item for each of the child types' do
      child_types = alternate_page.allowed_child_classes - [alternate_page.default_child]
      child_items_string = alternate_page.child_items.join
      child_types.each do |child|
        child_items_string.should match(/<li><a.+title="#{child.description}".+>/)
      end
    end
    it 'should not return a default_child_item' do
      alternate_page.child_items.should_not include(alternate_page.default_child_item)
    end
    it 'should not return a separator' do
      alternate_page.child_items.should_not include(alternate_page.separator_item)
    end
  end

  describe '#menu_items' do
    it 'should return a collection of the default child, separator and menu items' do
      default_child_item = Object.new
      special_page.stub!(:default_child_item).and_return(default_child_item)
      separator_item = Object.new
      special_page.stub!(:separator_item).and_return(separator_item)
      child = Object.new
      child_items = [child]
      special_page.stub!(:child_items).and_return(child_items)
      special_page.menu_items.should == [default_child_item, separator_item, child]
    end
  end

  describe '#menu_list' do
    it 'should return a list of all menu items' do
      special_page.stub!(:menu_items).and_return(['-- menu items --'])
      special_page.menu_list.should match(/<ul class="menu" id="allowed_children_#{special_page.id}">-- menu items --<\/ul>/)
    end
  end

  describe '#remove_link' do
    it 'should return a link to remove the page' do
      I18n.stub!(:t).with('remove').and_return('Remove')
      path = '/page/remove/url'
      view.stub!(:remove_admin_page_url).and_return(path)
      image = 'image'
      view.stub!(:image).and_return(image)
      special_page.remove_link.should match(/<a href="#{path}" class="action">#{image} Remove<\/a>/)
    end
  end

  describe '#remove_option' do
    it 'should return the remove_link' do
      link = '-- remove link --'
      special_page.stub!(:remove_link).and_return(link)
      special_page.remove_option.should == link
    end
  end

  describe '#add_child_disabled?' do
    it 'should return true if there are no allowed_child_classes' do
      special_page.stub!(:allowed_child_classes).and_return([])
      special_page.add_child_disabled?.should be_true
    end
    it 'should return false if there are allowed_child_classes' do
      special_page.stub!(:allowed_child_classes).and_return(['yes'])
      special_page.add_child_disabled?.should be_false
    end
  end

  describe '#disabled_add_child_link' do
    it 'should not contain a link' do
      view.stub!(:image).and_return('image')
      special_page.disabled_add_child_link.should_not match('<a.*href=')
    end
    it 'should have a disable image' do
      image = 'disabled'
      view.stub!(:image).and_return(image)
      special_page.disabled_add_child_link.should match(/#{image}/)
    end
    it 'should have a disable image' do
      image = 'disabled'
      view.stub!(:image).and_return(image)
      special_page.disabled_add_child_link.should match(/#{image}/)
    end
  end

  describe '#add_child_link' do
    it 'should contain a link to the new page form' do
      I18n.stub!(:t).with('add_child').and_return('Add Child')
      special_page.stub!(:default_child).and_return(AlternatePage)
      path = '/pages/new?page_class=' + special_page.default_child.name
      view.stub!(:new_admin_page_child_path).and_return path
      view.stub!(:image).and_return 'image'
      special_page.add_child_link.should match(/<a href="#{Regexp.quote(path)}".*>#{view.image} Add Child/)
    end
  end

  describe '#add_child_link_with_menu_hook' do
    it 'should contain a link to the new menu element' do
      I18n.stub!(:t).with('add_child').and_return('Add Child')
      special_page.stub!(:default_child).and_return(AlternatePage)
      path = '/pages/new?page_class=' + special_page.default_child.name
      view.stub!(:new_admin_page_child_path).and_return path
      view.stub!(:image).and_return 'image'
      special_page.add_child_link_with_menu_hook.should match(/<a href="#allowed_children_#{special_page.id}".*class="[^"]*dropdown">/)
    end
  end

  describe '#add_child_menu' do
    it 'should return the menu_list' do
      special_page.stub!(:menu_list).and_return('-- menu list --')
      special_page.add_child_menu.should == '-- menu list --'
    end
  end

  describe '#add_child_link_with_menu' do
    it 'should return the add_child_link_with_menu_hook and the add_child_menu' do
      special_page.stub!(:add_child_link_with_menu_hook).and_return('link with hook ')
      special_page.stub!(:add_child_menu).and_return(' -- menu')
      special_page.add_child_link_with_menu.should == 'link with hook  -- menu'
    end
  end

  describe '#add_child_option' do
    it 'should return a disabled link if add child is disabled' do
      special_page.stub!(:add_child_disabled?).and_return(true)
      special_page.stub!(:disabled_add_child_link).and_return(' disabled link ')
      special_page.add_child_option.should == ' disabled link '
    end
    it 'should return an add child link if add child is not disabled and the allowed_child_classes count is 1' do
      special_page.stub!(:add_child_disabled?).and_return(false)
      special_page.stub!(:allowed_child_classes).and_return([Page])
      special_page.stub!(:add_child_link).and_return(' link ')
      special_page.add_child_option.should == ' link '
    end
    it 'should return an add child link with menu if add child is not disabled and the allowed_child_classes count is greater than 1' do
      special_page.stub!(:add_child_disabled?).and_return(false)
      special_page.stub!(:allowed_child_classes).and_return([Page, AlternatePage])
      special_page.stub!(:add_child_link_with_menu).and_return(' link with menu ')
      special_page.add_child_option.should == ' link with menu '
    end
  end

end