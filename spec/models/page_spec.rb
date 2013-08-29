require File.dirname(__FILE__) + '/../spec_helper'

class PageSpecTestPage < Page
  description 'this is just a test page'

  def headers
    {
      'cool' => 'beans',
      'request' => @request.inspect[20..30],
      'response' => @response.inspect[20..31]
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
      other = Page.new(page_params.merge(:parent_id => 1))
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
      page.attributes = { :class_name => 'PageSpecTestPage' }
      expect(page.errors_on(:class_name)).to be_blank
      expect(page.class_name).to be_eql('PageSpecTestPage')
    end

    it 'should not be valid when class name is not a descendant of page' do
      page.class_name = 'Object'
      expect(page.errors_on(:class_name)).to include('must be set to a valid descendant of Page')
    end

    it 'should not be valid when class name is not a descendant of page and it is set through mass assignment' do
      page.attributes = {:class_name => 'Object' }
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
    page_with_layout.layout.name.should == "Main Layout"
  end

  it 'should be inherited' do
    child_page.layout_id.should == nil
    child_page.layout.should == page_with_layout.layout
  end
end

describe Page do
  let(:page){ FactoryGirl.create(:page) }
  let(:parent){ pages(:parent) }
  let(:child){ pages(:child) }
  let(:part){ page.parts(:body) }

  describe '#parts' do
    it 'should return PageParts with a page_id of the page id' do
      page.parts.sort_by{|p| p.name }.should == PagePart.find_all_by_page_id(page.id).sort_by{|p| p.name }
    end
  end

  it 'should destroy dependant parts' do
    page.parts << FactoryGirl.build(:page_part, name: 'test')
    page.parts.find_by_name('test').should_not be_nil
    id = page.id
    page.destroy
    PagePart.find_by_page_id(id).should be_nil
  end

  describe '#part' do
    it 'should find the part with a name of the given string' do
      page.part('body').should == page.parts.find_by_name('body')
    end
    it 'should find the part with a name of the given symbol' do
      page.part(:body).should == page.parts.find_by_name('body')
    end
    it 'should access unsaved parts by name' do
      part = PagePart.new(:name => "test")
      page.parts << part
      page.part('test').should == part
      page.part(:test).should == part
    end
    it 'should return nil for an invalid part name' do
      page.part('not-real').should be_nil
    end
  end

  describe '#field' do
    it "should find a field" do
      page.fields.create(:name => 'keywords', :content => 'radiant')
      page.field(:keywords).should == page.fields.find_by_name('keywords')
    end

    it "should find an unsaved field" do
      field = PageField.new(:name => 'description', :content => 'radiant')
      page.fields << field
      page.field(:description).should == field
    end
  end

  describe '#has_part?' do
    it 'should return true for a valid part' do
      page.parts.build(:name => 'body', :content => 'Hello world!')
      page.has_part?('body').should == true
      page.has_part?(:body).should == true
    end
    it 'should return false for a non-existant part' do
      page.has_part?('obviously_false_part_name').should == false
      page.has_part?(:obviously_false_part_name).should == false
    end
  end

  describe '#inherits_part?' do
    it 'should return true if any ancestor page has a part of the given name' do
      page.parts.create(:name => 'sidebar')
      child = FactoryGirl.build(:page) do |child|
        child.parent_id = page.id
      end
      child.has_part?(:sidebar).should be_false
      child.inherits_part?(:sidebar).should be_true
    end
    it 'should return false if any ancestor page does not have a part of the given name' do
      child = FactoryGirl.build(:page) do |child|
        child.parent_id = page.id
      end
      child.parts.build(:name => 'sidebar')
      child.has_part?(:sidebar).should be_true
      child.inherits_part?(:sidebar).should be_false
    end
  end

  describe '#has_or_inherits_part?' do
    let(:child){
      FactoryGirl.build(:page) do |child|
        child.parent_id = page.id
      end
    }
    before do
      page.parts.create(:name => 'sidebar')
    end
    it 'should return true if the current page or any ancestor has a part of the given name' do
      expect(child.has_or_inherits_part?(:sidebar)).to be_true
    end
    it 'should return false if the current part or any ancestor does not have a part of the given name' do
      expect(child.has_or_inherits_part?(:obviously_false_part_name)).to be_false
    end
  end

  it "should accept new page parts as an array of PageParts" do
    page.parts = [PagePart.new(:name => 'body', :content => 'Hello, world!')]
    page.parts.size.should == 1
    page.parts.first.should be_kind_of(PagePart)
    page.parts.first.name.should == 'body'
    page.parts.first.content.should == 'Hello, world!'
  end

  it "should dirty the page object when only changing parts" do
    lambda do
      page.dirty?.should be_false
      page.parts = [PagePart.new(:name => 'body', :content => 'Hello, world!')]
      page.dirty?.should be_true
    end
  end

  describe '#published?' do
    it "should be true when the status is Status[:published]" do
      page.status = Status[:published]
      page.published?.should be_true
    end
    it "should be false when the status is not Status[:published]" do
      page.status = Status[:draft]
      page.published?.should be_false
    end
  end

  describe '#scheduled?' do
    it "should be true when the status is Status[:scheduled]" do
      page.status = Status[:scheduled]
      page.scheduled?.should be_true
    end
    it "should be false when the status is not Status[:scheduled]" do
      page.status = Status[:published]
      page.scheduled?.should be_false
    end
  end

  context 'when setting the published_at date' do
    let(:future){ Time.current + 20.years }
    let(:past){ Time.current - 1.year }
    let(:future_scheduled){
      FactoryGirl.build(:page, :status_id => Status[:published].id, :published_at => future)
    }
    let(:past_scheduled){
      FactoryGirl.build(:page, :status_id => Status[:scheduled].id, :published_at => past)
    }

    it 'should change its status to scheduled with a date in the future' do
      future_scheduled.save

      expect(future_scheduled.status_id).to eq(Status[:scheduled].id)
    end

    it 'should set the status to published when the date is in the past' do
      past_scheduled.save

      expect(past_scheduled.status_id).to eq(Status[:published].id)
    end

    it 'should interpret the input date correctly when the current language is not English' do
      I18n.locale = :nl
      page.update_attribute(:published_at, "17 mei 2011")
      I18n.locale = :en
      expect(page.published_at.to_s(:db)).to eq('2013-05-17 00:00:00')
    end
  end

  context 'when setting the status' do
    let(:page){ FactoryGirl.build(:page, :status_id => Status[:published].id, :published_at => nil) }
    let(:scheduled){ FactoryGirl.build(:page, :status_id => Status[:scheduled].id, :published_at => (Time.current + 1.day)) }

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
      expect(page.published_at_changed?).to be_false
    end
  end

  describe '#path' do

    let(:home){ FactoryGirl.create(:page, :slug => '/', :published_at => Time.now) }
    let(:parent){ FactoryGirl.create(:page, :parent => home, :slug => 'parent', :published_at => Time.now) }
    let(:child){ FactoryGirl.create(:page, :parent => parent, :slug => 'child', :published_at => Time.now) }
    let(:grandchild){ FactoryGirl.create(:page, :parent => child, :slug => 'grandchild', :published_at => Time.now) }

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
    it 'should return the #path for the given child' do
      parent.child_path(child).should == '/parent/child/'
    end
  end

  describe '#status' do
    test_helper :page
    let(:home){ FactoryGirl.create(:page, :slug => '/', :published_at => Time.current) }

    it 'should return the Status with the id of the page status_id' do
      expect(home.status).to eq(Status.find(home.status_id))
    end

    it 'should set the status_id to the id of the given Status' do
      home.status = Status[:draft]
      expect(home.status_id).to eq(Status[:draft].id)
    end
  end

  its(:cache?){ should be_true }
  its(:virtual?){ should be_false }

  it 'should support optimistic locking' do
    p1, p2 = Page.find(page.id), Page.find(page.id)
    p1.update_attributes!(:breadcrumb => "foo")
    lambda { p2.update_attributes!(:breadcrumb => "blah") }.should raise_error(ActiveRecord::StaleObjectError)
  end

  describe '.default_child' do
    it 'should return the Page class' do
      Page.default_child.should == Page
    end
  end

  describe '#default_child' do
    it 'should return the class default_child' do
      page.default_child.should == Page.default_child
    end
  end

  describe '#allowed_children_lookup' do
    it 'should return the default_child as the first element' do
      page.allowed_children_lookup.first.should == page.default_child
    end

    it 'should return a collection containing the default_child and ordered by name Page descendants that are in_menu' do
      Page.should_receive(:descendants).and_return([PageSpecTestPage, CustomFileNotFoundPage])
      page.allowed_children_lookup.should == [Page, CustomFileNotFoundPage, PageSpecTestPage]
    end
  end
end

describe Page, "before save filter" do
  #dataset :home_page

  before :each do
    Page.create(page_params(:title =>"Month Index", :class_name => "VirtualSpecPage"))
    @page = Page.find_by_title("Month Index")
  end

  it 'should set the class name correctly' do
    @page.should be_kind_of(VirtualSpecPage)
  end

  it 'should set the virtual bit correctly' do
    @page.virtual?.should == true
    @page.virtual.should == true
  end

  it 'should update virtual based on new class name' do
    # turn a regular page into a virtual page
    @page.class_name = "VirtualSpecPage"
    @page.save.should == true
    @page.virtual?.should == true
    @page.send(:read_attribute, :virtual).should == true

   # turn a virtual page into a non-virtual one
   ["", nil, "Page", "PageSpecTestPage"].each do |value|
      @page = PageSpecTestPage.create(page_params)
      @page.class_name = value
      @page.save.should == true
      @page = Page.find @page.id
      @page.should be_instance_of(Page.descendant_class(value))
      @page.virtual?.should == false
      @page.send(:read_attribute, :virtual).should == false
    end
  end
end

describe Page, "rendering" do
  #dataset :pages, :markup_pages, :layouts
  test_helper :render

  before :each do
    @page = pages(:home)
  end

  it 'should render' do
    @page.render.should == 'Hello world!'
  end

  it 'should render with a filter' do
    pages(:textile).render.should == 'Some *Textile* content. - Filtered with TEXTILE!'
  end

  it 'should render with tags' do
    pages(:radius).render.should == "Radius body."
  end

  it 'should render with a layout' do
    @page.update_attribute(:layout_id, layout_id(:main))
    @page.render.should == "<html>\n  <head>\n    <title>Home</title>\n  </head>\n  <body>\n    Hello world!\n  </body>\n</html>\n"
  end

  it 'should render a part' do
    @page.render_part(:body).should == "Hello world!"
  end

  it "should render blank when given a non-existent part" do
    @page.render_part(:empty).should == ''
  end

  it 'should render custom pages with tags' do
    create_page "Test Page", :body => "<r:test1 /> <r:test2 />", :class_name => "PageSpecTestPage"
    pages(:test_page).should render_as('Hello world! Another test. body.')
  end

  it 'should render custom pages with tags that return frozen strings' do
    create_page "Test Page", :body => "<r:frozen_string />", :class_name => "PageSpecTestPage"
    pages(:test_page).should render_as('Brain body.')
  end

  it 'should render blank when containing no content' do
    Page.new.should render_as('')
  end
end

unless defined?(::CustomFileNotFoundPage)
  class ::CustomFileNotFoundPage < FileNotFoundPage
  end
end

describe Page, "#find_by_path" do
  test_helper :page

  let(:home){ Page.create!(page_params(:slug => '/', :published_at => Time.now)) }
  let(:parent){ home.children.create!(page_params(:slug => 'parent', :published_at => Time.now))}
  let(:child){ parent.children.create!(page_params(:slug => 'child', :published_at => Time.now))}
  let(:grandchild){ child.children.create!(page_params(:slug => 'grandchild', :published_at => Time.now))}
  let(:great_grandchild){ grandchild.children.create!(page_params(:slug => 'great-grandchild', :published_at => Time.now))}
  let(:file_not_found){ FileNotFoundPage.create!(page_params(parent_id: home.id, :slug => '404', :published_at => Time.now))}
  let(:drafts){ home.children.create!(page_params(:slug => 'drafts', :status => Status[:draft])) }
  let(:lonely_draft_file_not_found){ FileNotFoundPage.create!(page_params(:parent_id => drafts.id, :status_id => Status[:draft].id)) }
  let(:gallery){ home.children.create!(page_params(:slug => 'gallery'))}
  let(:draft){ home.children.create!(page_params(:slug => 'draft')) }
  let(:no_picture){ FileNotFoundPage.create!(page_params(:slug => 'no-picture', :parent_id => gallery.id, :class_name => 'CustomFileNotFoundPage'))}

  it 'should allow you to find the home page' do
    expect(home.find_by_path('/')).to eq(home)
  end

  it 'should allow you to find deeply nested pages' do
    # ensure great_grandchild exists:
    great_grandchild
    expect(home.find_by_path('/parent/child/grandchild/great-grandchild/')).to eq(great_grandchild)
  end

  it 'should not allow you to find virtual pages' do
    file_not_found
    expect(home.find_by_path('/virtual/')).to eq(file_not_found)
  end

  it 'should find the FileNotFoundPage when a page does not exist' do
    file_not_found
    expect(home.find_by_path('/nothing-doing/')).to eq(file_not_found)
  end

  it 'should find a draft FileNotFoundPage in dev mode' do
    lonely_draft_file_not_found
    expect(home.find_by_path('/drafts/no-page-here', false)).to eq(lonely_draft_file_not_found.becomes(FileNotFoundPage))
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
    home.find_by_path('/draft/').should == file_not_found
  end

  it 'should find draft pages in dev mode' do
    draft
    expect(home.find_by_path('/draft/', false)).to eq(draft)
  end

  it "should use the top-most published 404 page by default" do
    file_not_found
    home.find_by_path('/foo').should == file_not_found
    home.find_by_path('/foo/bar').should == file_not_found
  end
end

describe Page, "class" do
  it 'should have a description' do
    PageSpecTestPage.description.should == 'this is just a test page'
  end

  it 'should have a display name' do
    Page.display_name.should == "Page"

    PageSpecTestPage.display_name.should == "Page Spec Test"

    PageSpecTestPage.display_name = "New Name"
    PageSpecTestPage.display_name.should == "New Name"

    FileNotFoundPage.display_name.should == "File Not Found"
  end

  it 'should list decendants' do
    descendants = Page.descendants
    assert_kind_of Array, descendants
    assert_match /PageSpecTestPage/, descendants.inspect
  end

  it 'should allow initialization with empty defaults' do
    @page = Page.new_with_defaults({})
    @page.parts.size.should == 0
  end

  it 'should allow initialization with default page parts' do
    @page = Page.new_with_defaults({ 'defaults.page.parts' => 'a, b, c'})
    @page.parts.size.should == 3
    @page.parts.first.name.should == 'a'
    @page.parts.last.name.should == 'c'
  end

  it 'should allow initialization with default page status' do
    @page = Page.new_with_defaults({ 'defaults.page.status' => 'published' })
    @page.status.should == Status[:published]
  end

  it 'should allow initialization with default filter' do
    @page = Page.new_with_defaults({ 'defaults.page.filter' => 'Textile', 'defaults.page.parts' => 'a, b, c' })
    @page.parts.each do |part|
      part.filter_id.should == 'Textile'
    end
  end

  it "should allow initialization with default fields" do
    @page = Page.new_with_defaults({ 'defaults.page.fields' => 'x, y, z' })
    @page.fields.size.should == 3
    @page.fields.first.name.should == 'x'
    @page.fields.last.name.should == 'z'
  end

  it "should expose default page parts" do
    override = PagePart.new(:name => 'override')
    Page.stub!(:default_page_parts).and_return([override])
    @page = Page.new_with_defaults({})
    @page.parts.should eql([override])
  end

  it 'should allow you to get the class name of a descendant class with a string' do
    ["", nil, "Page"].each do |value|
      Page.descendant_class(value).should == Page
    end
    Page.descendant_class("PageSpecTestPage").should == PageSpecTestPage
  end

  it 'should allow you to determine if a string is a valid descendant class name' do
    ["", nil, "Page", "PageSpecTestPage"].each do |value|
      Page.is_descendant_class_name?(value).should == true
    end
    Page.is_descendant_class_name?("InvalidPage").should == false
  end

  describe ".date_column_names" do
    it "should return an array of column names whose sql_type is a date, datetime or timestamp" do
      Page.date_column_names.should == Page.columns.collect{|c| c.name if c.sql_type =~ /^date(time)?|timestamp/ }.compact
    end
  end
end

describe Page, "loading subclasses before bootstrap" do
  before :each do
    Page.connection.should_receive(:tables).and_return([])
  end

  it "should not attempt to search for missing subclasses" do
    Page.connection.should_not_receive(:select_values).with("SELECT DISTINCT class_name FROM pages WHERE class_name <> '' AND class_name IS NOT NULL")
    Page.load_subclasses
  end
end

describe Page, "loading subclasses when upgrading from 0.5.x where class_name column is not present" do
  before :each do
    column_names = Page.column_names - ["class_name"]
    Page.should_receive(:column_names).and_return(column_names)
  end

  it "should not attempt to search for missing subclasses" do
    Page.connection.should_not_receive(:select_values).with("SELECT DISTINCT class_name FROM pages WHERE class_name <> '' AND class_name IS NOT NULL")
    Page.load_subclasses
  end
end

describe Page, 'loading subclasses after bootstrap' do
  it "should find subclasses in extensions" do
    defined?(BasicExtensionPage).should_not be_nil
  end

  it "should not adjust the display name of subclasses found in extensions" do
    BasicExtensionPage.display_name.should_not match(/not installed/)
  end
end

describe Page, "class which is applied to a page but not defined" do
  #dataset :pages

  before :each do
    Object.send(:const_set, :ClassNotDefinedPage, Class.new(Page){ def self.missing?; false end })
    create_page "Class Not Defined", :class_name => "ClassNotDefinedPage"
    Object.send(:remove_const, :ClassNotDefinedPage)
    Page.load_subclasses
  end

  it 'should be created dynamically as a new subclass of Page' do
    Object.const_defined?("ClassNotDefinedPage").should == true
  end

  it 'should indicate that it wasn\'t defined' do
    ClassNotDefinedPage.missing?.should == true
  end

  it "should adjust the display name to indicate that the page type is not installed" do
    ClassNotDefinedPage.display_name.should match(/not installed/)
  end

  after :each do
    Object.send(:remove_const, :ClassNotDefinedPage)
  end
end

describe Page, "class find_by_path" do
  test_helper :page

  let(:home){ Page.create!(page_params(:slug => '/', :published_at => Time.now)) }
  let(:parent){ home.children.create!(page_params(:slug => 'parent', :published_at => Time.now))}
  let(:child){ parent.children.create!(page_params(:slug => 'child', :published_at => Time.now))}
  let(:draft){ home.children.create!(page_params(:slug => 'draft', :status_id => Status[:draft].id)) }
  let(:file_not_found){ FileNotFoundPage.create!(page_params(parent_id: home.id, :slug => '404', :published_at => Time.now))}

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
    @request = ActionController::TestRequest.new :url => '/page/'
    @response = ActionController::TestResponse.new
    @page = FactoryGirl.build(:page) do |page|
      page.parts.build(:name => 'body', :content => 'Hello world!')
    end
  end

  it 'should set response body' do
    @page.process(@request, @response)
    @response.body.should match(/Hello world!/)
  end

  it 'should set headers and pass request and response' do
    create_page "Test Page", :class_name => "PageSpecTestPage"
    @page = pages(:test_page)
    @page.process(@request, @response)
    @response.headers['cool'].should == 'beans'
    @response.headers['request'].should == 'TestRequest'
    @response.headers['response'].should == 'TestResponse'
  end

  it 'should set content type based on layout' do
    @page = FactoryGirl.build(:page)
    @page.layout = FactoryGirl.build(:utf8_layout)
    @page.process(@request, @response)
    @response.should be_success
    @response.headers['Content-Type'].should == 'text/html;charset=utf8'
  end

  it "should copy custom headers into the response" do
    @page.stub!(:headers).and_return({"X-Extra-Header" => "This is my header"})
    @page.process(@request, @response)
    @response.header['X-Extra-Header'].should == "This is my header"
  end

  it "should set a 200 status code by default" do
    @page.process(@request, @response)
    @response.response_code.should == 200
  end

  it "should set the response code to the result of the response_code method on the page" do
    @page.stub!(:response_code).and_return(404)
    @page.process(@request, @response)
    @response.response_code.should == 404
  end

end
