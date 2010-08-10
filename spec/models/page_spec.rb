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

  tag 'test1' do
    'Hello world!'
  end

  tag 'test2' do
    'Another test.'
  end
end

describe Page, 'validations' do
  dataset :pages
  test_helper :validations
  
  let(:page){ Page.new(page_params)}

  before :each do
    @page = @model = Page.new(page_params)
  end
  
  it 'should not be valid with a slug length greater than 100 characters' do
    page.valid?.should be_true
    page.slug = 'x'*101
    page.valid?.should be_false
  end
  
  it 'should not be valid with a title length greater than 255 characters' do
    page.valid?.should be_true
    page.title = 'x'*256
    page.valid?.should be_false
  end
  
  it 'should not be valid with a breadcrumb length greater than 160 characters' do
    page.valid?.should be_true
    page.breadcrumb = 'x'*161
    page.valid?.should be_false
  end

  it 'should validate length of' do
    {
      :title => 255,
      :slug => 100,
      :breadcrumb => 160
    }.each do |field, max|
      assert_invalid field, ('this must not be longer than %d characters' % max), 'x' * (max + 1)
      assert_valid field, 'x' * max
    end
  end

  it 'should validate presence of' do
    [:title, :slug, :breadcrumb].each do |field|
      assert_invalid field, 'this must not be blank', '', ' ', nil
    end
  end

  it 'should validate format of' do
    @page.parent = pages(:home)
    assert_valid :slug, 'abc', 'abcd-efg', 'abcd_efg', 'abc.html', '/', '123'
    assert_invalid :slug, 'this does not match the expected format', 'abcd efg', ' abcd', 'abcd/efg'
  end

  it 'should validate numericality of' do
    assert_invalid :status_id, 'this must not be blank', '', nil
    [:id, :status_id, :parent_id].each do |field|
      assert_valid field, '1', '2'
      assert_invalid field, 'this must be a number', 'abcd', '1,2', '1.3'
    end
  end

  it 'should validate uniqueness of' do
    @page.parent = pages(:parent)
    assert_invalid :slug, 'this slug is already in use by a sibling of this page', 'child', 'child-2', 'child-3'
    assert_valid :slug, 'child-4'
  end

  it 'should allow mass assignment for class name' do
    @page.attributes = { :class_name => 'ArchivePage' }
    assert_valid @page
    @page.class_name.should == 'ArchivePage'
  end

  it 'should not be valid when class name is not a descendant of page' do
    @page.class_name = 'Object'
    @page.valid?.should == false
    assert_not_nil @page.errors.on(:class_name)
    @page.errors.on(:class_name).should == 'must be set to a valid descendant of Page'
  end

  it 'should not be valid when class name is not a descendant of page and it is set through mass assignment' do
    @page.attributes = {:class_name => 'Object' }
    @page.valid?.should == false
    assert_not_nil @page.errors.on(:class_name)
    @page.errors.on(:class_name).should == 'must be set to a valid descendant of Page'
  end

  it 'should be valid when class name is page or empty or nil' do
    [nil, '', 'Page'].each do |value|
      @page = ArchivePage.new(page_params)
      @page.class_name = value
      assert_valid @page
      @page.class_name.should == value
    end
  end
end

describe Page, "behaviors" do
  it 'should include' do
    Page.included_modules.should include(StandardTags)
    Page.included_modules.should include(Annotatable)
  end
end

describe Page, "layout" do
  dataset :pages_with_layouts

  it 'should be accessible' do
    @page = pages(:first)
    @page.layout_id.should == layout_id(:main)
    @page.layout.name.should == "Main"
  end

  it 'should be inherited' do
    @page = pages(:inherited_layout)
    @page.layout_id.should == nil
    @page.layout.should == @page.parent.layout
  end
end

describe Page do
  dataset :pages
  
  let(:page){ pages(:first ) }
  let(:home){ pages(:home) }
  let(:parent){ pages(:parent) }
  let(:child){ pages(:child) }
  let(:part){ page.parts(:body) }

  describe '#parts' do
    it 'should return PageParts with a page_id of the page id' do
      home.parts.sort_by{|p| p.name }.should == PagePart.find_all_by_page_id(home.id).sort_by{|p| p.name }
    end
  end

  it 'should destroy dependant parts' do
    page.parts.create(page_part_params(:name => 'test'))
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
    it 'should return nil string for an invalid part name' do
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
      child.has_part?(:sidebar).should be_false
      child.inherits_part?(:sidebar).should be_true
    end
    it 'should return false if any ancestor page does not have a part of the given name' do
      home.has_part?(:sidebar).should be_true
      home.inherits_part?(:sidebar).should be_false
    end
  end
  
  describe '#has_or_inherits_part?' do
    it 'should return true if the current page or any ancestor has a part of the given name' do
      child.has_or_inherits_part?(:sidebar).should be_true
    end
    it 'should return false if the current part or any ancestor does not have a part of the given name' do
      child.has_or_inherits_part?(:obviously_false_part_name).should be_false
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
    it 'should change its status to scheduled with a date in the future' do
      new_page = Page.new(page_params(:status_id => '100', :published_at => '2020-1-1'))
      new_page.save
      new_page.status_id.should == 90 
    end
    it 'should set the status to published when the date is in the past' do
      scheduled_time = Time.zone.now - 1.year
      p = Page.new(page_params(:status_id => '90', :published_at => scheduled_time))
      p.save
      p.status_id.should == 100
    end
  end
  
  context 'when setting the status' do  
    it 'should set published_at when given the published status id' do
      page = Page.new(page_params(:status_id => '100', :published_at => nil))
      page.status_id = Status[:published].id
      page.save
      page.published_at.utc.day.should == Time.now.utc.day
    end
    it 'should change its status to draft when set to draft' do
      scheduled = pages(:scheduled)
      scheduled.status_id = '1'
      scheduled.save
      scheduled.status_id.should == 1
    end
    it 'should not update published_at when already published' do
      new_page = Page.new(page_params(:status_id => Status[:published].id))
      expected = new_page.published_at
      new_page.save
      new_page.published_at.should == expected
    end
  end
    
  describe '#url' do
    it "should start with a slash" do
      page.url.should match(/^\//)
    end
    it "should return a string with the current page's slug catenated with it's ancestor's slugs and delimited by slashes" do
      pages(:grandchild).url.should == '/parent/child/grandchild/'
    end
    it 'should end with a slash' do
      page.url.should match(/\/$/)
    end
  end
  
  describe '#child_url' do
    it 'should return the #url for the given child' do
      parent.child_url(child).should == '/parent/child/'
    end
  end
  
  describe '#status' do
    it 'should return the Status with the id of the page status_id' do
      home.status.should == Status.find(home.status_id)
    end
  end

  describe '#status=' do
    it 'should set the status_id to the id of the given Status' do
      home.status = Status[:draft]
      home.status_id.should == Status[:draft].id
    end
  end

  its(:cache?){ should be_true }
  its(:virtual?){ should be_false }

  it 'should support optimistic locking' do
    p1, p2 = Page.find(page_id(:first)), Page.find(page_id(:first))
    p1.update_attributes!(:breadcrumb => "foo")
    lambda { p2.update_attributes!(:breadcrumb => "blah") }.should raise_error(ActiveRecord::StaleObjectError)
  end
end

describe Page, "before save filter" do
  dataset :home_page

  before :each do
    Page.create(page_params(:title =>"Month Index", :class_name => "ArchiveMonthIndexPage"))
    @page = Page.find_by_title("Month Index")
  end

  it 'should set the class name correctly' do
    @page.should be_kind_of(ArchiveMonthIndexPage)
  end

  it 'should set the virtual bit correctly' do
    @page.virtual?.should == true
    @page.virtual.should == true
  end

  it 'should update virtual based on new class name' do
    # turn a regular page into a virtual page
    @page.class_name = "ArchiveMonthIndexPage"
    @page.save.should == true
    @page.virtual?.should == true
    @page.send(:read_attribute, :virtual).should == true

   # turn a virtual page into a non-virtual one
   ["", nil, "Page", "EnvDumpPage"].each do |value|
      @page = ArchiveYearIndexPage.create(page_params)
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
  dataset :pages, :markup_pages, :snippets, :layouts
  test_helper :render

  before :each do
    @page = pages(:home)
  end

  it 'should render' do
    @page.render.should == 'Hello world!'
  end

  it 'should render with a filter' do
    pages(:textile).render.should == '<p>Some <strong>Textile</strong> content.</p>'
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

  it 'should render a snippet' do
    @page.render_snippet(snippets(:first)).should == 'test'
  end

  it 'should render a snippet with a filter' do
    @page.render_snippet(snippets(:markdown)).should match(%r{<p><strong>markdown</strong></p>})
  end

  it 'should render a snippet with a tag' do
    @page.render_snippet(snippets(:radius)).should == 'Home'
  end

  it 'should render custom pages with tags' do
    create_page "Test Page", :body => "<r:test1 /> <r:test2 />", :class_name => "PageSpecTestPage"
    pages(:test_page).should render_as('Hello world! Another test. body.')
  end
end

describe Page, "#find_by_url" do
  dataset :pages, :file_not_found

  before :each do
    @page = pages(:home)
  end

  it 'should allow you to find the home page' do
    @page.find_by_url('/').should == @page
  end

  it 'should allow you to find deeply nested pages' do
    @page.find_by_url('/parent/child/grandchild/great-grandchild/').should == pages(:great_grandchild)
  end

  it 'should not allow you to find virtual pages' do
    @page.find_by_url('/virtual/').should == pages(:file_not_found)
  end

  it 'should find the FileNotFoundPage when a page does not exist' do
    @page.find_by_url('/nothing-doing/').should == pages(:file_not_found)
  end

  it 'should find a draft FileNotFoundPage in dev mode' do
    @page.find_by_url('/drafts/no-page-here', false).should == pages(:lonely_draft_file_not_found)
  end

  it 'should not find a draft FileNotFoundPage in live mode' do
    @page.find_by_url('/drafts/no-page-here').should_not == pages(:lonely_draft_file_not_found)
  end

  it 'should find a custom file not found page' do
    @page.find_by_url('/gallery/nothing-doing').should == pages(:no_picture)
  end

  it 'should not find draft pages in live mode' do
    @page.find_by_url('/draft/').should == pages(:file_not_found)
  end

  it 'should find draft pages in dev mode' do
    @page.find_by_url('/draft/', false).should == pages(:draft)
  end

  it "should use the top-most published 404 page by default" do
    @page.find_by_url('/foo').should == pages(:file_not_found)
    @page.find_by_url('/foo/bar').should == pages(:file_not_found)
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
    defined?(ArchivePage).should_not be_nil
  end

  it "should not adjust the display name of subclasses found in extensions" do
    ArchivePage.display_name.should_not match(/not installed/)
  end
end

describe Page, "class which is applied to a page but not defined" do
  dataset :pages

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

describe Page, "class find_by_url" do
  dataset :pages, :file_not_found

  it 'should find the home page' do
    Page.find_by_url('/').should == pages(:home)
  end

  it 'should find children' do
    Page.find_by_url('/parent/child/').should == pages(:child)
  end

  it 'should not find draft pages in live mode' do
    Page.find_by_url('/draft/').should == pages(:file_not_found)
    Page.find_by_url('/draft/', false).should == pages(:draft)
  end

  it 'should raise an exception when root page is missing' do
    pages(:home).destroy
    Page.find_by_parent_id().should be_nil
    lambda { Page.find_by_url "/" }.should raise_error(Page::MissingRootPageError, 'Database missing root page')
  end
end

describe Page, "processing" do
  dataset :pages_with_layouts

  before :all do
    @request = ActionController::TestRequest.new :url => '/page/'
    @response = ActionController::TestResponse.new
    @page = pages(:home)
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
    @page = pages(:utf8)
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
