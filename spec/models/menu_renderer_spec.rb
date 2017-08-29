require 'rspec'
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
    allow(alternate_page).to receive(:view).and_return(view)
    alternate_page
  }
  let(:special_page){
    special_page_class = SpecialChildPage
    special_page = OpenStruct.new(class_name: 'SpecialTestPage', view: view, class: special_page_class)
    special_page.extend MenuRenderer
    special_page
  }

  context 'excluding classes from child list' do
    it 'adds to a collection of excluded classes' do
      expect{ MenuRenderer.exclude 'Page' }.not_to raise_error
    end
    it 'should be retrievable by the extended object' do
      MenuRenderer.exclude 'Page', 'SpecialPage'
      page = Object.new
      page.extend MenuRenderer
      expect(page.excluded_class_names).to include('Page')
      expect(page.excluded_class_names).to include('SpecialPage')
    end
  end

  it 'should allow you to set a view object for accessing helpers' do
    page = Object.new
    page.extend MenuRenderer
    view = Object.new
    page.view = view
    expect(page.view).to eq(view)
  end

  describe '#additional_menu_features?' do
    it 'should be true if there is another renderer module' do
      expect(special_page.additional_menu_features?).to be true
    end
    it 'should not be true if there is no additional renderer module' do
      special_page.class_name = 'MoreSpecialTestPage'
      expect(special_page.additional_menu_features?).not_to be true
    end
  end

  describe '#menu_renderer_module_name' do
    it 'should return the conventional name of an additonal module' do
      expect(special_page.menu_renderer_module_name).to eq('SpecialTestMenuRenderer')
    end
    it 'should return the module name if the class_name is nil' do
      allow(special_page).to receive(:class_name).and_return(nil)
      expect(special_page.menu_renderer_module_name).to eq('MenuRenderer')
    end
  end

  describe '#menu_renderer_modules' do
    it 'should return a collection of modules for additional extension' do
      expect(special_page.menu_renderer_modules).to eq([SpecialTestMenuRenderer])
    end
  end

  describe '#allowed_child_classes' do
    it 'should return a collection of classes to be used for child pages' do
      MenuRenderer.instance_variable_set(:@excluded_class_names,[])
      special_page.allowed_children_cache = 'Page,SpecialChildPage'
      expect(special_page.allowed_child_classes).to eq([Page, SpecialChildPage])
    end
    it 'should exclude any MenuRenderer excluded classes' do
      expect(special_page).to receive(:excluded_class_names).and_return ['SpecialChildPage']
      special_page.allowed_children_cache = 'Page,SpecialChildPage'
      expect(special_page.allowed_child_classes).to eq([Page])
    end
    it 'should not error when the allowed_children_cache is nil' do
      special_page.allowed_children_cache = nil
      expect{
        special_page.allowed_child_classes
      }.not_to raise_error
    end
    it 'should not raise error when the allowed_children_cache is unable to find a class' do
      special_page.allowed_children_cache = 'Page, SpecialChildPa' #the last class name is truncated by limit in database
      expect{
        special_page.allowed_child_classes
      }.not_to raise_error
    end
  end

  describe '#default_child_item' do
    before do
      @link_text = 'New Page Link'
      expect(I18n).to receive(:t).and_return(@link_text)
      allow(view).to receive(:new_admin_page_child_path).and_return'/pages/new'
      special_page.default_child = SpecialChildPage
    end
    it 'should return a menu item for the default child type' do
      expect(special_page.default_child_item).to match(/<li><a href="[^"]*".*>#{@link_text}<\/a><\/li>/)
    end
    it 'should have a title from the child class description' do
      title_text = 'A very special child...'
      expect(SpecialChildPage).to receive(:description).and_return(title_text)
      expect(special_page.default_child_item).to match(/<a .*title="#{title_text}">/)
    end
  end

  describe '#separator_item' do
    before do
      special_page.default_child = SpecialChildPage
    end
    it 'should return a menu item with no content' do
      expect(special_page.separator_item).to match(/<li[^>]*><\/li>/)
    end
    it 'should have a CSS class set for styling' do
      expect(special_page.separator_item).to match(/class="separator"/)
    end
  end

  describe '#child_items' do
    before do
      allow(alternate_page).to receive(:allowed_child_classes).and_return [Page, SpecialChildPage, SuperSpecialChildPage]
      allow(AlternatePage).to receive(:default_child).and_return(SpecialChildPage)
      allow(view).to receive(:new_admin_page_child_path).and_return'/pages/new'
    end
    it 'should return a menu item for each of the child types' do
      child_types = alternate_page.allowed_child_classes - [alternate_page.default_child]
      child_items_string = alternate_page.child_items.join
      child_types.each do |child|
        expect(child_items_string).to match(/<li><a.+title="#{child.description}".+>/)
      end
    end
    it 'should not return a default_child_item' do
      expect(alternate_page.child_items).not_to include(alternate_page.default_child_item)
    end
    it 'should not return a separator' do
      expect(alternate_page.child_items).not_to include(alternate_page.separator_item)
    end
  end

  describe '#menu_items' do
    it 'should return a collection of the default child, separator and menu items' do
      default_child_item = Object.new
      allow(special_page).to receive(:default_child_item).and_return(default_child_item)
      separator_item = Object.new
      allow(special_page).to receive(:separator_item).and_return(separator_item)
      child = Object.new
      child_items = [child]
      allow(special_page).to receive(:child_items).and_return(child_items)
      expect(special_page.menu_items).to eq([default_child_item, separator_item, child])
    end
  end

  describe '#menu_list' do
    it 'should return a list of all menu items' do
      allow(special_page).to receive(:menu_items).and_return(['-- menu items --'])
      expect(special_page.menu_list).to match(/<ul class="menu" id="allowed_children_#{special_page.id}">-- menu items --<\/ul>/)
    end
  end

  describe '#remove_link' do
    it 'should return a link to remove the page' do
      allow(I18n).to receive(:t).with('remove').and_return('Remove')
      path = '/page/remove/url'
      allow(view).to receive(:remove_admin_page_url).and_return(path)
      image = 'image'
      allow(view).to receive(:image).and_return(image)
      expect(special_page.remove_link).to match(/<a href="#{path}" class="action">#{image} Remove<\/a>/)
    end
  end

  describe '#remove_option' do
    it 'should return the remove_link' do
      link = '-- remove link --'
      allow(special_page).to receive(:remove_link).and_return(link)
      expect(special_page.remove_option).to eq(link)
    end
  end

  describe '#add_child_disabled?' do
    it 'should return true if there are no allowed_child_classes' do
      allow(special_page).to receive(:allowed_child_classes).and_return([])
      expect(special_page.add_child_disabled?).to be true
    end
    it 'should return false if there are allowed_child_classes' do
      allow(special_page).to receive(:allowed_child_classes).and_return(['yes'])
      expect(special_page.add_child_disabled?).to be false
    end
  end

  describe '#disabled_add_child_link' do
    it 'should not contain a link' do
      allow(view).to receive(:image).and_return('image')
      expect(special_page.disabled_add_child_link).not_to match('<a.*href=')
    end
    it 'should have a disable image' do
      image = 'disabled'
      allow(view).to receive(:image).and_return(image)
      expect(special_page.disabled_add_child_link).to match(/#{image}/)
    end
    it 'should have a disable image' do
      image = 'disabled'
      allow(view).to receive(:image).and_return(image)
      expect(special_page.disabled_add_child_link).to match(/#{image}/)
    end
  end

  describe '#add_child_link' do
    it 'should contain a link to the new page form' do
      allow(I18n).to receive(:t).with('add_child').and_return('Add Child')
      allow(special_page).to receive(:default_child).and_return(AlternatePage)
      path = '/pages/new?page_class=' + special_page.default_child.name
      allow(view).to receive(:new_admin_page_child_path).and_return path
      allow(view).to receive(:image).and_return 'image'
      expect(special_page.add_child_link).to match(/<a href="#{Regexp.quote(path)}".*>#{view.image} Add Child/)
    end
  end

  describe '#add_child_link_with_menu_hook' do
    it 'should contain a link to the new menu element' do
      allow(I18n).to receive(:t).with('add_child').and_return('Add Child')
      allow(special_page).to receive(:default_child).and_return(AlternatePage)
      path = '/pages/new?page_class=' + special_page.default_child.name
      allow(view).to receive(:new_admin_page_child_path).and_return path
      allow(view).to receive(:image).and_return 'image'
      expect(special_page.add_child_link_with_menu_hook).to match(/<a href="#allowed_children_#{special_page.id}".*class="[^"]*dropdown">/)
    end
  end

  describe '#add_child_menu' do
    it 'should return the menu_list' do
      allow(special_page).to receive(:menu_list).and_return('-- menu list --')
      expect(special_page.add_child_menu).to eq('-- menu list --')
    end
  end

  describe '#add_child_link_with_menu' do
    it 'should return the add_child_link_with_menu_hook and the add_child_menu' do
      allow(special_page).to receive(:add_child_link_with_menu_hook).and_return('link with hook ')
      allow(special_page).to receive(:add_child_menu).and_return(' -- menu')
      expect(special_page.add_child_link_with_menu).to eq('link with hook  -- menu')
    end
  end

  describe '#add_child_option' do
    it 'should return a disabled link if add child is disabled' do
      allow(special_page).to receive(:add_child_disabled?).and_return(true)
      allow(special_page).to receive(:disabled_add_child_link).and_return(' disabled link ')
      expect(special_page.add_child_option).to eq(' disabled link ')
    end
    it 'should return an add child link if add child is not disabled and the allowed_child_classes count is 1' do
      allow(special_page).to receive(:add_child_disabled?).and_return(false)
      allow(special_page).to receive(:allowed_child_classes).and_return([Page])
      allow(special_page).to receive(:add_child_link).and_return(' link ')
      expect(special_page.add_child_option).to eq(' link ')
    end
    it 'should return an add child link with menu if add child is not disabled and the allowed_child_classes count is greater than 1' do
      allow(special_page).to receive(:add_child_disabled?).and_return(false)
      allow(special_page).to receive(:allowed_child_classes).and_return([Page, AlternatePage])
      allow(special_page).to receive(:add_child_link_with_menu).and_return(' link with menu ')
      expect(special_page.add_child_option).to eq(' link with menu ')
    end
  end

end