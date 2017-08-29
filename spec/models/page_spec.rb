require File.dirname(__FILE__) + '/../spec_helper'

class PageSpecTestPage < Page
  description 'this is just a test page'

  def headers
    {
      'cool' => 'beans',
      'request' => @request.inspect[18..28],
      'response' => @response.inspect[18..29]
    }
  end

  tag 'test1' do |tag|
    'Hello world!'
  end

  tag 'test2' do |tag|
    'Another test.'
  end

  tag 'frozen_string' do |tag|
    'Brain'.freeze
  end
end

class VirtualSpecPage < Page
  def virtual?
    true
  end
end

class ReverseFilter < TextFilter
  description %{Reverses text.}
  def filter(text)
    text.reverse
  end
end

describe Page, 'validations' do
  test_helper :page

  let(:page){ FactoryGirl.build(:page) }

  describe 'breadcrumb' do

    it 'is invalid when longer than 160 characters' do
      page.breadcrumb = 'x' * 161
      expect(page.errors_on(:breadcrumb)).to include('this must not be longer than 160 characters')
    end

    it 'is invalid when blank' do
      page.breadcrumb = ''
      expect(page.errors_on(:breadcrumb)).to include("this must not be blank")
    end

    it 'is valid when 160 characters or shorter' do
      page.breadcrumb = 'x' * 160
      expect(page.errors_on(:breadcrumb)).to be_blank
    end

  end

  describe 'slug' do

    it 'is invalid when longer than 100 characters' do
      page.slug = 'x' * 101
      expect(page.errors_on(:slug)).to include('this must not be longer than 100 characters')
    end

    it 'is invalid when blank' do
      page.slug = ''
      expect(page.errors_on(:slug)).to include("this must not be blank")
    end

    it 'is valid when 100 characters or shorter' do
      page.slug = 'x' * 100
      expect(page.errors_on(:slug)).to be_blank
    end

    it 'is invalid when in the incorrect format' do
      ['this does not match the expected format', 'abcd efg', ' abcd', 'abcd/efg'].each do |sample|
        page.slug = sample
        expect(page.errors_on(:slug)).to include('this does not match the expected format')
      end
    end

    it 'is invalid when the same value exists with the same parent' do
      page.parent_id = 1
      page.save!
      other = Page.new(page_params.merge(parent_id: 1))
      expect{other.save!}.to raise_error(ActiveRecord::RecordInvalid)
      expect(other.errors_on(:slug)).to include(I18n.t('activerecord.errors.models.page.attributes.slug.taken'))
    end

  end

  describe 'title' do

    it 'is invalid when longer than 255 characters' do
      page.title = 'x' * 256
      expect(page.errors_on(:title)).to include('this must not be longer than 255 characters')
    end

    it 'is invalid when blank' do
      page.title = ''
      expect(page.errors_on(:title)).to include("this must not be blank")
    end

    it 'is valid when 255 characters or shorter' do
      page.title = 'x' * 255
      expect(page.errors_on(:title)).to be_blank
    end

  end

  describe 'class_name' do
    it 'should allow mass assignment for class name' do
      page.attributes = { class_name: 'PageSpecTestPage' }
      expect(page.errors_on(:class_name)).to be_blank
      expect(page.class_name).to be_eql('PageSpecTestPage')
    end

    it 'should not be valid when class name is not a descendant of page' do
      page.class_name = 'Object'
      expect(page.errors_on(:class_name)).to include('must be set to a valid descendant of Page')
    end

    it 'should not be valid when class name is not a descendant of page and it is set through mass assignment' do
      page.attributes = {class_name: 'Object' }
      expect(page.errors_on(:class_name)).to include('must be set to a valid descendant of Page')
    end

    it 'should be valid when class name is page or empty or nil' do
      [nil, '', 'Page'].each do |value|
        page = PageSpecTestPage.new(page_params)
        page.class_name = value
        expect(page.errors_on(:class_name)).to be_blank
        expect(page.class_name).to be_eql(value)
      end
    end
  end
end

describe Page, "layout" do
  let(:page_with_layout){ FactoryGirl.create(:page_with_layout) }
  let(:child_page){ FactoryGirl.build(:page) do |child|
      child.parent_id = page_with_layout.id
    end }

  it 'should be accessible' do
    expect(page_with_layout.layout.name).to eq("Main Layout")
  end

  it 'should be inherited' do
    expect(child_page.layout_id).to eq(nil)
    expect(child_page.layout).to eq(page_with_layout.layout)
  end
end

describe Page do
  let(:page){ FactoryGirl.create(:page) }
  let(:parent){ pages(:parent) }
  let(:child){ pages(:child) }
  let(:part){ page.parts(:body) }

  describe '#parts' do
    it 'should return PageParts with a page_id of the page id' do
      expect(page.parts.sort_by{|p| p.name }).to eq(PagePart.where(page_id: page.id).sort_by{|p| p.name })
    end
  end

  it 'should destroy dependant parts' do
    page.parts << FactoryGirl.build(:page_part, name: 'test')
    expect(page.parts.find_by_name('test')).not_to be_nil
    id = page.id
    page.destroy
    expect(PagePart.find_by_page_id(id)).to be_nil
  end

  describe '#part' do
    it 'should find the part with a name of the given string' do
      expect(page.part('body')).to eq(page.parts.find_by_name('body'))
    end
    it 'should find the part with a name of the given symbol' do
      expect(page.part(:body)).to eq(page.parts.find_by_name('body'))
    end
    it 'should access unsaved parts by name' do
      part = PagePart.new(name: "test")
      page.parts << part
      expect(page.part('test')).to eq(part)
      expect(page.part(:test)).to eq(part)
    end
    it 'should return nil for an invalid part name' do
      expect(page.part('not-real')).to be_nil
    end
  end

  describe '#field' do
    it "should find a field" do
      page.fields.create(name: 'keywords', content: 'radiant')
      expect(page.field(:keywords)).to eq(page.fields.find_by_name('keywords'))
    end

    it "should find an unsaved field" do
      field = PageField.new(name: 'description', content: 'radiant')
      page.fields << field
      expect(page.field(:description)).to eq(field)
    end
  end

  describe '#has_part?' do
    it 'should return true for a valid part' do
      page.parts.build(name: 'body', content: 'Hello world!')
      expect(page.has_part?('body')).to eq(true)
      expect(page.has_part?(:body)).to eq(true)
    end
    it 'should return false for a non-existant part' do
      expect(page.has_part?('obviously_false_part_name')).to eq(false)
      expect(page.has_part?(:obviously_false_part_name)).to eq(false)
    end
  end

  describe '#inherits_part?' do
    it 'should return true if any ancestor page has a part of the given name' do
      page.parts.create(name: 'sidebar')
      child = FactoryGirl.build(:page) do |child|
        child.parent_id = page.id
      end
      expect(child.has_part?(:sidebar)).to be false
      expect(child.inherits_part?(:sidebar)).to be true
    end
    it 'should return false if any ancestor page does not have a part of the given name' do
      child = FactoryGirl.build(:page) do |child|
        child.parent_id = page.id
      end
      child.parts.build(name: 'sidebar')
      expect(child.has_part?(:sidebar)).to be true
      expect(child.inherits_part?(:sidebar)).to be false
    end
  end

  describe '#has_or_inherits_part?' do
    let(:child){
      FactoryGirl.build(:page) do |child|
        child.parent_id = page.id
      end
    }
    before do
      page.parts.create(name: 'sidebar')
    end
    it 'should return true if the current page or any ancestor has a part of the given name' do
      expect(child.has_or_inherits_part?(:sidebar)).to be true
    end
    it 'should return false if the current part or any ancestor does not have a part of the given name' do
      expect(child.has_or_inherits_part?(:obviously_false_part_name)).to be false
    end
  end

  it "should accept new page parts as an array of PageParts" do
    page.parts = [PagePart.new(name: 'body', content: 'Hello, world!')]
    expect(page.parts.size).to eq(1)
    expect(page.parts.first).to be_kind_of(PagePart)
    expect(page.parts.first.name).to eq('body')
    expect(page.parts.first.content).to eq('Hello, world!')
  end

  it "should dirty the page object when only changing parts" do
    lambda do
      expect(page.dirty?).to be false
      page.parts = [PagePart.new(name: 'body', content: 'Hello, world!')]
      expect(page.dirty?).to be true
    end
  end

  describe '#published?' do
    it "should be true when the status is Status[:published]" do
      page.status = Status[:published]
      expect(page.published?).to be true
    end
    it "should be false when the status is not Status[:published]" do
      page.status = Status[:draft]
      expect(page.published?).to be false
    end
  end

  describe '#scheduled?' do
    it "should be true when the status is Status[:scheduled]" do
      page.status = Status[:scheduled]
      expect(page.scheduled?).to be true
    end
    it "should be false when the status is not Status[:scheduled]" do
      page.status = Status[:published]
      expect(page.scheduled?).to be false
    end
  end

  context 'when setting the published_at date' do
    let(:future){ Time.current + 20.years }
    let(:past){ Time.current - 1.year }
    let(:future_scheduled){
      FactoryGirl.build(:page, status_id: Status[:published].id, published_at: future)
    }
    let(:past_scheduled){
      FactoryGirl.build(:page, status_id: Status[:scheduled].id, published_at: past)
    }

    it 'should change its status to scheduled with a date in the future' do
      future_scheduled.save

      expect(future_scheduled.status_id).to eq(Status[:scheduled].id)
    end

    it 'should set the status to published when the date is in the past' do
      past_scheduled.save

      expect(past_scheduled.status_id).to eq(Status[:published].id)
    end

    xit 'should interpret the input date correctly when the current language is not English' do
      I18n.locale = :nl
      page.update_attribute(:published_at, "17 mei 2011")
      I18n.locale = :en
      expect(page.published_at.to_s(:db)).to eq('2013-05-17 00:00:00')
    end
  end

  context 'when setting the status' do
    let(:page){ FactoryGirl.build(:page, status_id: Status[:published].id, published_at: nil) }
    let(:scheduled){ FactoryGirl.build(:page, status_id: Status[:scheduled].id, published_at: (Time.current + 1.day)) }

    it 'should set published_at when given the published status id' do
      page.save

      expect(page.published_at.utc.day).to eq(Time.now.utc.day)
    end

    it 'should change its status to draft when set to draft' do
      scheduled.status_id = Status[:draft].id
      scheduled.save

      expect(scheduled.status_id).to eq(Status[:draft].id)
    end

    it 'should not update published_at when already published' do
      page.save

      page.save
      expect(page.published_at_changed?).to be false
    end
  end

  describe '#path' do

    let(:home){ FactoryGirl.create(:page, slug: '/', published_at: Time.now) }
    let(:parent){ FactoryGirl.create(:page, parent: home, slug: 'parent', published_at: Time.now) }
    let(:child){ FactoryGirl.create(:page, parent: parent, slug: 'child', published_at: Time.now) }
    let(:grandchild){ FactoryGirl.create(:page, parent: child, slug: 'grandchild', published_at: Time.now) }

    it "should start with a slash" do
      expect(home.path).to match(/\A\//)
    end
    it "should return a string with the current page's slug catenated with it's ancestor's slugs and delimited by slashes" do
      expect(grandchild.path).to eq('/parent/child/grandchild/')
    end
    it 'should end with a slash' do
      expect(page.path).to match(/\/\z/)
    end
  end

  describe '#child_path' do

    let(:home){ FactoryGirl.create(:page, slug: '/', published_at: Time.now) }
    let(:parent){ FactoryGirl.create(:page, parent: home, slug: 'parent', published_at: Time.now) }
    let(:child){ FactoryGirl.create(:page, parent: parent, slug: 'child', published_at: Time.now) }

    it 'should return the #path for the given child' do
      expect(parent.child_path(child)).to eq('/parent/child/')
    end
  end

  describe '#status' do
    test_helper :page
    let(:home){ FactoryGirl.create(:page, slug: '/', published_at: Time.current) }

    it 'should return the Status with the id of the page status_id' do
      expect(home.status).to eq(Status.find(home.status_id))
    end

    it 'should set the status_id to the id of the given Status' do
      home.status = Status[:draft]
      expect(home.status_id).to eq(Status[:draft].id)
    end
  end

  describe '#cache?' do
    subject { super().cache? }
    it { is_expected.to be true }
  end

  describe '#virtual?' do
    subject { super().virtual? }
    it { is_expected.to be false }
  end

  it 'should support optimistic locking' do
    p1, p2 = Page.find(page.id), Page.find(page.id)
    p1.update_attributes!(breadcrumb: "foo")
    expect { p2.update_attributes!(breadcrumb: "blah") }.to raise_error(ActiveRecord::StaleObjectError)
  end

  describe '.default_child' do
    it 'should return the Page class' do
      expect(Page.default_child).to eq(Page)
    end
  end

  describe '#default_child' do
    it 'should return the class default_child' do
      expect(page.default_child).to eq(Page.default_child)
    end
  end

  describe '#allowed_children_lookup' do
    it 'should return the default_child as the first element' do
      expect(page.allowed_children_lookup.first).to eq(page.default_child)
    end

    it 'should return a collection containing the default_child and ordered by name Page descendants that are in_menu' do
      expect(Page).to receive(:descendants).at_least(:once).and_return([PageSpecTestPage, CustomFileNotFoundPage])
      expect(page.allowed_children_lookup).to eq([Page, CustomFileNotFoundPage, PageSpecTestPage])
    end
  end
end

describe Page, "before save filter" do

  before :each do
    Page.create(FactoryGirl.attributes_for(:page, title:"Month Index", class_name: "VirtualSpecPage"))
    @page = Page.find_by_title("Month Index")
  end

  it 'should set the class name correctly' do
    expect(@page).to be_kind_of(VirtualSpecPage)
  end

  it 'should set the virtual bit correctly' do
    expect(@page.virtual?).to eq(true)
    expect(@page.virtual).to eq(true)
  end

  it 'should update virtual based on new class name' do
    # turn a regular page into a virtual page
    @page.class_name = "VirtualSpecPage"
    expect(@page.save).to eq(true)
    expect(@page.virtual?).to eq(true)
    expect(@page.send(:read_attribute, :virtual)).to eq(true)

   # turn a virtual page into a non-virtual one
   ["", nil, "Page", "PageSpecTestPage"].each do |value|
      @page.class_name = value
      expect(@page.save).to eq(true)
      @page = Page.find @page.id
      expect(@page).to be_instance_of(Page.descendant_class(value))
      expect(@page.virtual?).to eq(false)
      expect(@page.send(:read_attribute, :virtual)).to eq(false)
    end
  end
end

describe Page, "rendering" do
  test_helper :render
  let(:hello_world){
    FactoryGirl.build(:page) do |page|
      page.parts.build(name: 'body', content: 'Hello world!')
    end
  }
  let(:reverse_filtered){
    FactoryGirl.build(:page) do |page|
      page.parts.build(name: 'body', content: 'Hello world!', filter_id: 'Reverse')
    end
  }
  let(:radius){
    FactoryGirl.build(:page, title: 'Radius') do |page|
      page.parts.build(name: 'body', content: '<r:title />')
    end
  }
  let(:test_page){
    PageSpecTestPage.create(FactoryGirl.attributes_for(:page, title: "Test Page")) do |page|
      page.parts.build(name: 'body', content: '<r:test1 /> <r:test2 />')
    end
  }
  
  it 'should render' do
    expect(hello_world.render).to eq('Hello world!')
  end

  it 'should render with a filter' do
    expect(reverse_filtered.render).to eq('!dlrow olleH')
  end

  it 'should render with tags' do
    expect(radius.render).to eq("Radius")
  end

  it 'should render with a layout' do
    hello_world.update_attribute(:layout_id, FactoryGirl.create(:layout).id)
    expect(hello_world.render).to eq("<html>\n  <head>\n    <title>Page</title>\n  </head>\n  <body>\n    Hello world!\n  </body>\n</html>\n")
  end

  it 'should render a part' do
    expect(hello_world.render_part(:body)).to eq("Hello world!")
  end

  it "should render blank when given a non-existent part" do
    expect(hello_world.render_part(:empty)).to eq('')
  end

  it 'should render custom pages with tags' do
    expect(test_page).to render_as('Hello world! Another test.')
  end

  it 'should render custom pages with tags that return frozen strings' do
    test_page.part(:body).update_attribute :content, '<r:frozen_string />'
    expect(test_page).to render_as('Brain')
  end

  it 'should render blank when containing no content' do
    expect(Page.new).to render_as('')
  end
end

unless defined?(::CustomFileNotFoundPage)
  class ::CustomFileNotFoundPage < FileNotFoundPage
  end
end

describe Page, "#find_by_path" do
  let(:home){ FactoryGirl.create(:page, slug: '/', published_at: Time.now, status_id: Status[:published].id) }
  let(:parent){ FactoryGirl.create(:page, parent: home, slug: 'parent', published_at: Time.now, status_id: Status[:published].id)}
  let(:child){ FactoryGirl.create(:page, parent: parent, slug: 'child', published_at: Time.now, status_id: Status[:published].id)}
  let(:grandchild){ FactoryGirl.create(:page, parent: child, slug: 'grandchild', published_at: Time.now, status_id: Status[:published].id)}
  let(:great_grandchild){ FactoryGirl.create(:page, parent: grandchild, slug: 'great-grandchild', published_at: Time.now, status_id: Status[:published].id)}
  let(:virtual){ FactoryGirl.create(:page, parent_id: home.id, slug: 'virtual', virtual: true) }
  let(:file_not_found){ FactoryGirl.create(:file_not_found_page, parent_id: home.id, slug: '404', published_at: Time.now, status_id: Status[:published].id)}
  let(:drafts){ FactoryGirl.create(:page, parent: home, slug: 'drafts', status_id: Status[:draft].id) }
  let(:lonely_draft_file_not_found){ FactoryGirl.create(:file_not_found_page, parent_id: drafts.id, status_id: Status[:draft].id) }
  let(:gallery){ FactoryGirl.create(:page, parent: home, slug: 'gallery', status_id: Status[:published].id)}
  let(:draft){ FactoryGirl.create(:page, parent: home, slug: 'draft', status_id: Status[:published].id) }
  let(:no_picture){ FactoryGirl.create(:file_not_found_page, slug: 'no-picture', parent_id: gallery.id, class_name: 'CustomFileNotFoundPage', status_id: Status[:published].id)}

  it 'should allow you to find the home page' do
    expect(home.find_by_path('/')).to eq(home)
  end

  it 'should allow you to find deeply nested pages' do
    # ensure great_grandchild exists:
    great_grandchild
    expect(home.find_by_path('/parent/child/grandchild/great-grandchild/')).to eq(great_grandchild)
  end

  it 'should not allow you to find virtual pages' do
    virtual
    file_not_found
    expect(home.find_by_path('/virtual/')).to eq(file_not_found)
  end

  it 'should find the FileNotFoundPage when a page does not exist' do
    file_not_found
    expect(home.find_by_path('/nothing-doing/')).to eq(file_not_found)
  end

  it 'should find a draft FileNotFoundPage in dev mode' do
    lonely_draft_file_not_found
    expect(home.find_by_path('/drafts/no-page-here', false)).to eq(lonely_draft_file_not_found)
  end

  it 'should not find a draft FileNotFoundPage in live mode' do
    lonely_draft_file_not_found
    expect(home.find_by_path('/drafts/no-page-here', true)).to_not eq(lonely_draft_file_not_found)
  end

  it 'should find a custom file not found page' do
    no_picture
    expect(home.find_by_path('/gallery/nothing-doing')).to eq(no_picture.becomes(CustomFileNotFoundPage))
  end

  it 'should not find draft pages in live mode' do
    file_not_found
    expect(home.find_by_path('/draft/')).to eq(file_not_found)
  end

  it 'should find draft pages in dev mode' do
    draft
    expect(home.find_by_path('/draft/', false)).to eq(draft)
  end

  it "should use the top-most published 404 page by default" do
    file_not_found
    expect(home.find_by_path('/foo')).to eq(file_not_found)
    expect(home.find_by_path('/foo/bar')).to eq(file_not_found)
  end
end

describe Page, "class" do
  it 'should have a description' do
    expect(PageSpecTestPage.description).to eq('this is just a test page')
  end

  it 'should have a display name' do
    expect(Page.display_name).to eq("Page")

    expect(PageSpecTestPage.display_name).to eq("Page Spec Test")

    PageSpecTestPage.display_name = "New Name"
    expect(PageSpecTestPage.display_name).to eq("New Name")

    expect(FileNotFoundPage.display_name).to eq("File Not Found")
  end

  it 'should list decendants' do
    descendants = Page.descendants
    assert_kind_of Array, descendants
    assert_match /PageSpecTestPage/, descendants.inspect
  end

  it 'should allow initialization with empty defaults' do
    @page = Page.new_with_defaults({})
    expect(@page.parts.size).to eq(0)
  end

  it 'should allow initialization with default page parts' do
    @page = Page.new_with_defaults({ 'defaults.page.parts' => 'a, b, c'})
    expect(@page.parts.size).to eq(3)
    expect(@page.parts.first.name).to eq('a')
    expect(@page.parts.last.name).to eq('c')
  end

  it 'should allow initialization with default page status' do
    @page = Page.new_with_defaults({ 'defaults.page.status' => 'published' })
    expect(@page.status).to eq(Status[:published])
  end

  it 'should allow initialization with default filter' do
    @page = Page.new_with_defaults({ 'defaults.page.filter' => 'Textile', 'defaults.page.parts' => 'a, b, c' })
    @page.parts.each do |part|
      expect(part.filter_id).to eq('Textile')
    end
  end

  it "should allow initialization with default fields" do
    @page = Page.new_with_defaults({ 'defaults.page.fields' => 'x, y, z' })
    expect(@page.fields.size).to eq(3)
    expect(@page.fields.first.name).to eq('x')
    expect(@page.fields.last.name).to eq('z')
  end

  it "should expose default page parts" do
    override = PagePart.new(name: 'override')
    allow(Page).to receive(:default_page_parts).and_return([override])
    @page = Page.new_with_defaults({})
    expect(@page.parts).to match_array([override])
  end

  it 'should allow you to get the class name of a descendant class with a string' do
    ["", nil, "Page"].each do |value|
      expect(Page.descendant_class(value)).to eq(Page)
    end
    expect(Page.descendant_class("PageSpecTestPage")).to eq(PageSpecTestPage)
  end

  it 'should allow you to determine if a string is a valid descendant class name' do
    ["", nil, "Page", "PageSpecTestPage"].each do |value|
      expect(Page.is_descendant_class_name?(value)).to eq(true)
    end
    expect(Page.is_descendant_class_name?("InvalidPage")).to eq(false)
  end

  describe ".date_column_names" do
    it "should return an array of column names whose sql_type is a date, datetime or timestamp" do
      expect(Page.date_column_names).to eq(Page.columns.collect{|c| c.name if c.sql_type =~ /^date(time)?|timestamp/ }.compact)
    end
  end
end

describe Page, "loading subclasses before bootstrap" do
  it "should not attempt to search for missing subclasses" do
    allow(Page.connection).to receive(:tables).and_return([])
    expect(Page.connection).not_to receive(:select_values).with("SELECT DISTINCT class_name FROM pages WHERE class_name <> '' AND class_name IS NOT NULL")
    Page.load_subclasses
  end
end

describe Page, "loading subclasses when upgrading from 0.5.x where class_name column is not present" do
  before :each do
    column_names = Page.column_names - ["class_name"]
    expect(Page).to receive(:column_names).and_return(column_names)
  end

  it "should not attempt to search for missing subclasses" do
    expect(Page.connection).not_to receive(:select_values).with("SELECT DISTINCT class_name FROM pages WHERE class_name <> '' AND class_name IS NOT NULL")
    Page.load_subclasses
  end
end

describe Page, 'loading subclasses after bootstrap' do
  xit "should find subclasses in extensions" do
    expect(defined?(BasicExtensionPage)).not_to be_nil
  end

  xit "should not adjust the display name of subclasses found in extensions" do
    expect(BasicExtensionPage.display_name).not_to match(/not installed/)
  end
end

describe Page, "class which is applied to a page but not defined" do
  #dataset :pages

  before :each do
    Object.send(:const_set, :ClassNotDefinedPage, Class.new(Page){ def self.missing?; false end })
    FactoryGirl.create(:page, title: "Class Not Defined", class_name: "ClassNotDefinedPage")
    Object.send(:remove_const, :ClassNotDefinedPage)
    Page.load_subclasses
  end

  it 'should be created dynamically as a new subclass of Page' do
    expect(Object.const_defined?("ClassNotDefinedPage")).to eq(true)
  end

  it 'should indicate that it wasn\'t defined' do
    expect(ClassNotDefinedPage.missing?).to eq(true)
  end

  it "should adjust the display name to indicate that the page type is not installed" do
    expect(ClassNotDefinedPage.display_name).to match(/not installed/)
  end

  after :each do
    Object.send(:remove_const, :ClassNotDefinedPage)
  end
end

describe Page, "class find_by_path" do
  test_helper :page

  let(:home){ Page.create!(page_params(slug: '/', status_id: Status[:published].id)) }
  let(:parent){ home.children.create!(page_params(slug: 'parent', status_id: Status[:published].id))}
  let(:child){ parent.children.create!(page_params(slug: 'child', status_id: Status[:published].id))}
  let(:draft){ home.children.create!(page_params(slug: 'draft', status_id: Status[:draft].id)) }
  let(:file_not_found){ FileNotFoundPage.create!(page_params(parent_id: home.id, slug: '404', status_id: Status[:published].id))}

  it 'should find the home page' do
    home
    expect(Page.find_by_path('/')).to eq(home)
  end

  it 'should find children' do
    child
    expect(Page.find_by_path('/parent/child/')).to eq(child)
  end

  it 'should not find draft pages in live mode' do
    file_not_found
    draft
    expect(Page.find_by_path('/draft/')).to eq(file_not_found)
    expect(Page.find_by_path('/draft/', false)).to eq(draft)
  end

  it 'should raise an exception when root page is missing' do
    expect{Page.find_by_path("/")}.to raise_error(Page::MissingRootPageError, 'Database missing root page')
  end
end

describe Page, "processing" do

  before :all do
    @request = ActionDispatch::TestRequest.new url: '/page/'
    @response = ActionDispatch::TestResponse.new
    @page = FactoryGirl.build(:page) do |page|
      page.parts.build(name: 'body', content: 'Hello world!')
    end
  end

  it 'should set response body' do
    @page.process(@request, @response)
    expect(@response.body).to match(/Hello world!/)
  end

  it 'should set headers and pass request and response' do
    @page = PageSpecTestPage.create(FactoryGirl.attributes_for(:page, title: "Test Page"))
    @page.process(@request, @response)
    expect(@response.headers['cool']).to eq('beans')
    expect(@response.headers['request']).to eq('TestRequest')
    expect(@response.headers['response']).to eq('TestResponse')
  end

  it 'should set content type based on layout' do
    @page = FactoryGirl.build(:page)
    @page.layout = FactoryGirl.build(:utf8_layout)
    @page.process(@request, @response)
    expect(@response).to be_success
    expect(@response.headers['Content-Type']).to eq('text/html;charset=utf8')
  end

  it "should copy custom headers into the response" do
    allow(@page).to receive(:headers).and_return({"X-Extra-Header" => "This is my header"})
    @page.process(@request, @response)
    expect(@response.header['X-Extra-Header']).to eq("This is my header")
  end

  it "should set a 200 status code by default" do
    @page.process(@request, @response)
    expect(@response.response_code).to eq(200)
  end

  it "should set the response code to the result of the response_code method on the page" do
    allow(@page).to receive(:response_code).and_return(404)
    @page.process(@request, @response)
    expect(@response.response_code).to eq(404)
  end

end
