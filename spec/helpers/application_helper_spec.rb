require File.dirname(__FILE__) + "/../spec_helper"

describe ApplicationHelper do
  dataset :users

  before :each do
    Radiant::Initializer.run :initialize_default_admin_tabs
    helper.stub!(:request).and_return(ActionController::TestRequest.new)
  end
  
  it "should have the Radiant::Config" do
    helper.config.should == Radiant::Config
  end
  
  it "should use the default title if not configured" do
    helper.title.should == "Radiant CMS"
  end
  
  it "should use the stored title if configured" do
    helper.config['admin.title'] = "My Title"
    helper.title.should == "My Title"
  end

  it "should use the default subtitle if not configured" do
    helper.subtitle.should == "Publishing for Small Teams"
  end
  
  it "should use the stored title if configured" do
    helper.config['admin.subtitle'] = "My Subtitle"
    helper.subtitle.should == "My Subtitle"
  end
  
  it "should not be logged in before authentication" do
    helper.should_receive(:current_user).and_return(nil)
    helper.logged_in?.should be_false
  end
  
  it "should be logged in when authenticated" do
    helper.should_receive(:current_user).and_return(users(:existing))
    helper.logged_in?.should be_true
  end
  
  it "should create a button for a new model" do
    model = mock_model(Page)
    model.should_receive(:new_record?).and_return(true)
    helper.should_receive(:submit_tag).with("Create Page", :class => 'button', :accesskey=>"S")
    helper.save_model_button(model)
  end
  
  it "should create a button for an existing model" do
    model = mock_model(Page)
    model.should_receive(:new_record?).and_return(false)
    helper.should_receive(:submit_tag).with("Save Changes", :class => 'button', :accesskey=>"S")
    helper.save_model_button(model)
  end
  
  it "should create a button with custom options" do
    model = mock_model(Page)
    model.should_receive(:new_record?).and_return(false)
    helper.should_receive(:submit_tag).with("Save Changes", :class => 'custom', :accesskey=>"S")
    helper.save_model_button(model, :class => 'custom')
  end
  
  it "should create a button with a custom label" do
    model = mock_model(Page)
    helper.should_receive(:submit_tag).with("Create PAGE", :class => 'button', :accesskey=>"S")
    helper.save_model_button(model, :label => "Create PAGE")
  end
  
  it "should create a save and continue button" do
    model = mock_model(Page)
    helper.save_model_and_continue_editing_button(model).should =~ /name="continue"/
    helper.save_model_and_continue_editing_button(model).should =~ /class="button"/
    helper.save_model_and_continue_editing_button(model).should =~ /^<input/
  end
  
  it "should determine whether a given url matches the current url" do
    request = mock("request")
    helper.stub!(:request).and_return(request)
    request.stub!(:request_uri).and_return("/foo/bar")
    helper.current_url?("/foo/bar/").should_not be_false
    helper.current_url?("/foo//bar").should_not be_false
    helper.current_url?("/baz/bam").should_not be_true
    helper.current_url?(:controller => "admin/pages", :action => "index").should_not be_true
  end
  
  it "should clean a url" do
    helper.clean("/foo/////bar").should == "/foo/bar"
    helper.clean("/blah/").should == "/blah"
  end
  
  it "should render an admin navigation link" do
    request = mock("request")
    helper.stub!(:request).and_return(request)
    request.stub!(:request_uri).and_return("/admin/pages")
    helper.nav_link_to("Pages", "/admin/pages").should =~ /<strong>/
    helper.nav_link_to("Snippets", "/admin/snippets").should_not =~ /<strong>/
  end
  
  it "should render an admin link without translation" do
    helper.nav_link_to("Foo", "/admin/foo").should == '<a href="/admin/foo">Foo</a>'
  end
  
  it "should render an admin section link with translation" do
    helper.translate_with_default('Pages').should == 'Pages'
  end
  
  it "should render an admin section link without translation" do
    helper.translate_with_default('Foo').should == 'Foo'
  end
  
  it "should determine whether the current user is an admin" do
    helper.should_receive(:current_user).at_least(1).times.and_return(users(:admin))
    helper.admin?.should be_true
  end
  
  it "should determine whether the current user is a designer" do
    helper.should_receive(:current_user).at_least(1).times.and_return(users(:designer))
    helper.designer?.should be_true
  end
  
  it "should render a Javascript snippet that focuses a given field" do
    helper.focus('joe').should =~ Regexp.new(Regexp.quote("activate('joe')"))
  end
  
  it "should render an updated timestamp for a model" do
    model = mock_model(Page)
    model.should_receive(:new_record?).and_return(false)
    model.should_receive(:updated_by).and_return(users(:admin))
    model.should_receive(:updated_at).and_return(Time.local(2008, 3, 30, 10, 30))
    helper.updated_stamp(model).should == %{<p class="updated_line">Last Updated by <strong>Admin</strong> at 10:30 am on March 30, 2008</p>}
  end
  
  it "should render a timezone-adjusted timestamp" do
    helper.timestamp(Time.local(2008, 3, 30, 10, 30)).should == "10:30 am on March 30, 2008"
  end
  
  it "should determine whether a meta area item should be visible" do
    helper.meta_visible(:meta_more).should be_empty
    helper.meta_visible(:meta_less).should == {:style => "display: none"}
    helper.meta_visible(:meta).should == {:style => "display: none"}
  end
  
  it "should not have meta errors" do
    helper.meta_errors?.should be_false
  end
  
  it "should provide a meta_label of 'Less' when meta_errors? is true" do
    helper.stub!(:meta_errors?).and_return(true)
    helper.meta_label.should == 'Less'
  end
  
  it "should provide a meta_label of 'More' when meta_errors? is false" do
    helper.stub!(:meta_errors?).and_return(false)
    helper.meta_label.should == 'More'
  end
  
  it "should render a Javascript snippet to toggle the meta area" do
    helper.toggle_javascript_for("joe").should == "Element.toggle('joe'); Element.toggle('more-joe'); Element.toggle('less-joe'); return false;"
  end
  
  it "should render an image tag with a default file extension" do
    helper.should_receive(:image_tag).with("admin/plus.png", {})
    helper.image("plus")
  end
  
  it "should render an image submit tag with a default file extension" do
    helper.should_receive(:image_submit_tag).with("admin/plus.png", {})
    helper.image_submit("plus")
  end
  
  it "should provide the admin object" do
    helper.admin.should == Radiant::AdminUI.instance
  end

  it "should return filter options for select" do
    helper.filter_options_for_select.should =~ %r{<option value=\"\">&lt;none&gt;</option>}
    helper.filter_options_for_select.should =~ %r{<option value=\"Markdown\">Markdown</option>}
  end 

  it "should include the regions helper" do
    ApplicationHelper.included_modules.should include(Admin::RegionsHelper)
  end
  
  describe 'stylesheet_and_javascript_overrides' do
    before do
      @override_css_path = "#{Rails.root}/public/stylesheets/admin/overrides.css"
      @override_sass_path = "#{Rails.root}/public/stylesheets/sass/admin/overrides.sass"
      @override_js_path = "#{Rails.root}/public/javascripts/admin/overrides.js"
      File.stub!(:exist?)
    end
    it "should render a link to the overrides.css file when it exists" do
      File.should_receive(:exist?).with(@override_css_path).and_return(true)
      helper.stylesheet_and_javascript_overrides.should have_tag('link[href*=?][media=?][rel=?][type=?]','/stylesheets/admin/overrides.css','screen','stylesheet','text/css')
    end
    it "should render a link to the overrides.css file when the overrides.sass file exists" do
      File.should_receive(:exist?).with(@override_sass_path).and_return(true)
      helper.stylesheet_and_javascript_overrides.should have_tag('link[href*=?][media=?][rel=?][type=?]','/stylesheets/admin/overrides.css','screen','stylesheet','text/css')
    end
    it "should not render a link to the overrides.css file when it does not exist" do
      File.should_receive(:exist?).at_least(:once).with(@override_css_path).and_return(false)
      helper.stylesheet_and_javascript_overrides.should_not have_tag('link[href*=?][media=?][rel=?][type=?]','/stylesheets/admin/overrides.css','screen','stylesheet','text/css')
    end
    it "should not render a link to the overrides.css file when the overrides.css and overrides.sass file does not exist" do
      File.should_receive(:exist?).at_least(:once).with(@override_css_path).and_return(false)
      File.should_receive(:exist?).at_least(:once).with(@override_sass_path).and_return(false)
      helper.stylesheet_and_javascript_overrides.should_not have_tag('link[href*=?][media=?][rel=?][type=?]','/stylesheets/admin/overrides.css','screen','stylesheet','text/css')
    end
    it "should render a link to the overrides.js file when it exists" do
      File.should_receive(:exist?).at_least(:once).with(@override_js_path).and_return(true)
      helper.stylesheet_and_javascript_overrides.should have_tag('script[src*=?][type=?]','/javascripts/admin/overrides.js', 'text/javascript')
    end
    it "should not render a link to the overrides.js file when it does not exist" do
      File.should_receive(:exist?).at_least(:once).with(@override_js_path).and_return(false)
      helper.stylesheet_and_javascript_overrides.should_not have_tag('script[src*=?][type=?]','/javascripts/admin/overrides.js', 'text/javascript')
    end
  end
  
  # describe "pagination" do
  #   before do
  #     @collection = WillPaginate::Collection.new(1, 10, 100)
  #     request = mock("request")
  #     helper.stub!(:request).and_return(request)
  #     helper.stub!(:will_paginate_options).and_return({})
  #     helper.stub!(:will_paginate).and_return("pagination of some kind")
  #     helper.stub!(:link_to).and_return("link")
  #   end
  #   
  #   it "should render pagination controls for a supplied list" do
  #     helper.pagination_for(@collection).should have_tag('div.pagination').with_tag('span.current', :text => '1')
  #   end
  #   
  #   it "should include a depagination link by default" do
  #     helper.pagination_for(@collection).should have_tag('div.depaginate')
  #   end
  #   
  #   it "should omit the depagination link when :depaginate is false" do
  #     helper.pagination_for(@collection, :depaginate => false).should_not have_tag('div.depaginate')
  #   end
  #   
  #   it "should omit the depagination link when the :max_list_length is exceeded" do
  #     helper.pagination_for(@collection, :depaginate => true, :max_list_length => 5).should_not have_tag('div.depaginate')
  #   end
  # 
  #   it "should use the max_list_length config item when no other value is specified" do
  #     Radiant::Config['pagination.max_list_length'] = 50
  #     helper.pagination_for(@collection).should_not have_tag('div.depaginate')
  #   end
  # 
  #   it "should disregard list length when max_list_length is false" do
  #     Radiant::Config['pagination.max_list_length'] = 50
  #     helper.pagination_for(@collection, :max_list_length => false).should_not have_tag('div.depaginate')
  #   end
  #   
  # end
end
