describe Radiant::ApplicationHelper do
  
  before :each do
    allow(helper).to receive(:request).and_return(ActionDispatch::TestRequest.new)
  end

  it "should have the Radiant::Config" do
    expect(helper.detail).to eq(Radiant::Config)
  end

  it "should use the default title if not configured" do
    expect(helper.title).to eq("Radiant CMS")
  end

  it "should use the stored title if configured" do
    helper.detail['admin.title'] = "My Title"
    expect(helper.title).to eq("My Title")
  end

  it "should use the default subtitle if not configured" do
    expect(helper.subtitle).to eq("Publishing for Small Teams")
  end

  it "should use the stored title if configured" do
    helper.detail['admin.subtitle'] = "My Subtitle"
    expect(helper.subtitle).to eq("My Subtitle")
  end

  it "should not be logged in before authentication" do
    expect(helper).to receive(:current_user).and_return(nil)
    expect(helper.logged_in?).to be false
  end

  it "should be logged in when authenticated" do
    expect(helper).to receive(:current_user).and_return(FactoryGirl.build(:user))
    expect(helper.logged_in?).to be true
  end

  it "should create a button for a new model" do
    model = mock_model(Page)
    expect(model).to receive(:new_record?).and_return(true)
    expect(helper).to receive(:submit_tag).with("Create Page", class: 'button', accesskey:"S")
    helper.save_model_button(model)
  end

  it "should create a button for an existing model" do
    model = mock_model(Page)
    expect(model).to receive(:new_record?).and_return(false)
    expect(helper).to receive(:submit_tag).with("Save Changes", class: 'button', accesskey:"S")
    helper.save_model_button(model)
  end

  it "should create a button with custom options" do
    model = mock_model(Page)
    expect(model).to receive(:new_record?).and_return(false)
    expect(helper).to receive(:submit_tag).with("Save Changes", class: 'custom', accesskey:"S")
    helper.save_model_button(model, class: 'custom')
  end

  it "should create a button with a custom label" do
    model = mock_model(Page)
    expect(helper).to receive(:submit_tag).with("Create PAGE", class: 'button', accesskey:"S")
    helper.save_model_button(model, label: "Create PAGE")
  end

  it "should create a save and continue button" do
    model = mock_model(Page)
    expect(helper.save_model_and_continue_editing_button(model)).to match(/name="continue"/)
    expect(helper.save_model_and_continue_editing_button(model)).to match(/class="button"/)
    expect(helper.save_model_and_continue_editing_button(model)).to match(/^<input/)
  end

  it "should determine whether a given url matches the current url" do
    request = double("request")
    allow(helper).to receive(:request).and_return(request)
    allow(request).to receive(:fullpath).and_return("/foo/bar")
    expect(helper.current_url?("/foo/bar/")).not_to be false
    expect(helper.current_url?("/foo//bar")).not_to be false
    expect(helper.current_url?("/baz/bam")).not_to be true
    expect(helper.current_url?(controller: "admin/pages", action: "index")).not_to be true
  end

  it "should clean a url" do
    expect(helper.clean("/foo/////bar")).to eq("/foo/bar")
    expect(helper.clean("/blah/")).to eq("/blah")
  end

  it "should render an admin navigation link" do
    request = double("request")
    allow(helper).to receive(:request).and_return(request)
    allow(request).to receive(:fullpath).and_return("/admin/pages")
    expect(helper.nav_link_to("Pages", "/admin/pages")).to match(/<strong>/)
  end

  it "should render an admin link without translation" do
    expect(helper.nav_link_to("Foo", "/admin/foo")).to eq('<a href="/admin/foo">Foo</a>')
  end

  it "should render an admin section link with translation" do
    expect(helper.translate_with_default('Pages')).to eq('Pages')
  end

  it "should render an admin section link without translation" do
    expect(helper.translate_with_default('Foo')).to eq('Foo')
  end

  it "should determine whether the current user is an admin" do
    expect(helper).to receive(:current_user).at_least(1).times.and_return(FactoryGirl.build(:admin))
    expect(helper.admin?).to be true
  end

  it "should determine whether the current user is a designer" do
    expect(helper).to receive(:current_user).at_least(1).times.and_return(FactoryGirl.build(:designer))
    expect(helper.designer?).to be true
  end

  it "should render a Javascript snippet that focuses a given field" do
    expect(helper.focus('joe')).to match(Regexp.new(Regexp.quote("activate('joe')")))
  end

  it "should render an updated timestamp for a model" do
    model = mock_model(Page)
    expect(model).to receive(:new_record?).and_return(false)
    expect(model).to receive(:updated_by).and_return(FactoryGirl.build(:admin))
    expect(model).to receive(:updated_at).and_return(Time.local(2008, 3, 30, 10, 30))
    expect(helper.updated_stamp(model)).to eq(%{<p class="updated_line">Last Updated by <strong>Admin</strong> at 10:30 am on March 30, 2008</p>})
  end

  it "should render a timezone-adjusted timestamp" do
    expect(helper.timestamp(Time.local(2008, 3, 30, 10, 30))).to eq("10:30 am on March 30, 2008")
  end

  it "should determine whether a meta area item should be visible" do
    expect(helper.meta_visible(:meta_more)).to be_empty
    expect(helper.meta_visible(:meta_less)).to eq({style: "display: none"})
    expect(helper.meta_visible(:meta)).to eq({style: "display: none"})
  end

  it "should not have meta errors" do
    expect(helper.meta_errors?).to be false
  end

  it "should provide a meta_label of 'Less' when meta_errors? is true" do
    allow(helper).to receive(:meta_errors?).and_return(true)
    expect(helper.meta_label).to eq('Less')
  end

  it "should provide a meta_label of 'More' when meta_errors? is false" do
    allow(helper).to receive(:meta_errors?).and_return(false)
    expect(helper.meta_label).to eq('More')
  end

  it "should render a Javascript snippet to toggle the meta area" do
    expect(helper.toggle_javascript_for("joe")).to eq("Element.toggle('joe'); Element.toggle('more-joe'); Element.toggle('less-joe'); return false;")
  end

  it "should render an image tag with a default file extension" do
    expect(helper).to receive(:image_tag).with("admin/plus.png", {})
    helper.image("plus")
  end

  it "should render an image submit tag with a default file extension" do
    expect(helper).to receive(:image_submit_tag).with("admin/plus.png", {})
    helper.image_submit("plus")
  end

  it "should provide the admin object" do
    expect(helper.admin).to eq(Radiant::AdminUI.instance)
  end

  it "should return filter options for select" do
    expect(helper.filter_options_for_select).to match(%r{<option value=\"\">&lt;none&gt;</option>})
    expect(helper.filter_options_for_select).to match(%r{<option value=\"Basic\">Basic</option>})
  end

  it "should include the regions helper" do
    expect(ApplicationHelper.included_modules).to include(Admin::RegionsHelper)
  end

  describe 'stylesheet_and_javascript_overrides' do
    before do
      @override_css_path = "#{Rails.root}/public/stylesheets/admin/overrides.css"
      @override_sass_path = "#{Rails.root}/public/stylesheets/sass/admin/overrides.sass"
      @override_js_path = "#{Rails.root}/public/javascripts/admin/overrides.js"
      allow(File).to receive(:exist?)
    end
    it "should render a link to the overrides.css file when it exists" do
      expect(File).to receive(:exist?).with(@override_css_path).and_return(true)
      expect(helper.stylesheet_and_javascript_overrides).to have_tag('link[href*=?][media=?][rel=?][type=?]','/stylesheets/admin/overrides.css','screen','stylesheet','text/css')
    end
    it "should render a link to the overrides.css file when the overrides.sass file exists" do
      expect(File).to receive(:exist?).with(@override_sass_path).and_return(true)
      expect(helper.stylesheet_and_javascript_overrides).to have_tag('link[href*=?][media=?][rel=?][type=?]','/stylesheets/admin/overrides.css','screen','stylesheet','text/css')
    end
    it "should not render a link to the overrides.css file when it does not exist" do
      expect(File).to receive(:exist?).at_least(:once).with(@override_css_path).and_return(false)
      expect(helper.stylesheet_and_javascript_overrides).not_to have_tag('link[href*=?][media=?][rel=?][type=?]','/stylesheets/admin/overrides.css','screen','stylesheet','text/css')
    end
    it "should not render a link to the overrides.css file when the overrides.css and overrides.sass file does not exist" do
      expect(File).to receive(:exist?).at_least(:once).with(@override_css_path).and_return(false)
      expect(File).to receive(:exist?).at_least(:once).with(@override_sass_path).and_return(false)
      expect(helper.stylesheet_and_javascript_overrides).not_to have_tag('link[href*=?][media=?][rel=?][type=?]','/stylesheets/admin/overrides.css','screen','stylesheet','text/css')
    end
    it "should render a link to the overrides.js file when it exists" do
      expect(File).to receive(:exist?).at_least(:once).with(@override_js_path).and_return(true)
      expect(helper.stylesheet_and_javascript_overrides).to have_tag('script[src*=?][type=?]','/javascripts/admin/overrides.js', 'text/javascript')
    end
    it "should not render a link to the overrides.js file when it does not exist" do
      expect(File).to receive(:exist?).at_least(:once).with(@override_js_path).and_return(false)
      expect(helper.stylesheet_and_javascript_overrides).not_to have_tag('script[src*=?][type=?]','/javascripts/admin/overrides.js', 'text/javascript')
    end
  end

  # describe "pagination" do
  #   before do
  #     @collection = WillPaginate::Collection.new(1, 10, 100)
  #     request = double("request")
  #     helper.stub(:request).and_return(request)
  #     helper.stub(:will_paginate_options).and_return({})
  #     helper.stub(:will_paginate).and_return("pagination of some kind")
  #     helper.stub(:link_to).and_return("link")
  #   end
  #
  #   it "should render pagination controls for a supplied list" do
  #     helper.pagination_for(@collection).should have_tag('div.pagination').with_tag('span.current', text: '1')
  #   end
  #
  #   it "should include a depagination link by default" do
  #     helper.pagination_for(@collection).should have_tag('div.depaginate')
  #   end
  #
  #   it "should omit the depagination link when :depaginate is false" do
  #     helper.pagination_for(@collection, depaginate: false).should_not have_tag('div.depaginate')
  #   end
  #
  #   it "should omit the depagination link when the :max_list_length is exceeded" do
  #     helper.pagination_for(@collection, depaginate: true, max_list_length: 5).should_not have_tag('div.depaginate')
  #   end
  #
  #   it "should use the max_list_length config item when no other value is specified" do
  #     Radiant::Config['pagination.max_list_length'] = 50
  #     helper.pagination_for(@collection).should_not have_tag('div.depaginate')
  #   end
  #
  #   it "should disregard list length when max_list_length is false" do
  #     Radiant::Config['pagination.max_list_length'] = 50
  #     helper.pagination_for(@collection, max_list_length: false).should_not have_tag('div.depaginate')
  #   end
  #
  # end
end
