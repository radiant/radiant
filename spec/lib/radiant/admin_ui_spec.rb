require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::AdminUI do
  before :each do
    @admin = Radiant::AdminUI.new
  end

  it "should be a Simpleton" do
    Radiant::AdminUI.included_modules.should include(Simpleton)
    Radiant::AdminUI.should respond_to(:instance)
  end

  it "should have a TabSet" do
    @admin.should respond_to(:tabs)
    @admin.tabs.should_not be_nil
    @admin.tabs.should be_instance_of(Radiant::AdminUI::TabSet)
  end

  it "should have collections of Region Sets for every controller" do
    %w{page snippet layout user}.each do |collection|
      @admin.should respond_to(collection)
      @admin.should respond_to(collection.pluralize)
      @admin.send(collection).should_not be_nil
      @admin.send(collection).should be_kind_of(OpenStruct)
    end
  end

  it "should load the default page regions" do
    page = @admin.page
    %w{edit remove children index}.each do |action|
      page.send(action).should_not be_nil
      page.send(action).should be_kind_of(Radiant::AdminUI::RegionSet)
    end
    page.edit.main.should == %w{edit_header edit_form edit_popups}
    page.edit.form.should == %w{edit_title edit_extended_metadata
                                edit_page_parts}
    page.edit.parts_bottom.should == %w{edit_layout_and_type edit_timestamp}
    page.edit.form_bottom.should == %w{edit_buttons}
    page.index.sitemap_head.should == %w{title_column_header
                                        status_column_header
                                        modify_column_header}
    page.index.node.should == %w{title_column status_column add_child_column
                                  remove_column}
    page.remove.should === page.index
    page.children.should === page.index
    page._part.should === page.edit
    page.new.should === page.edit
  end

  it "should load the default snippet regions" do
    snippet = @admin.snippet
    snippet.edit.should_not be_nil
    snippet.edit.main.should == %w{edit_header edit_form}
    snippet.edit.form.should == %w{edit_title edit_content edit_filter
                                   edit_timestamp}
    snippet.edit.form_bottom.should == %w{edit_buttons}
    snippet.index.should_not be_nil
    snippet.index.top.should == %w{help_text}
    snippet.index.thead.should == %w{title_header modify_header}
    snippet.index.tbody.should == %w{title_cell modify_cell}
    snippet.index.bottom.should == %w{new_button}

    snippet.new.should == snippet.edit
  end

  it "should load the default layout regions" do
    layout = @admin.layout
    layout.edit.should_not be_nil
    layout.edit.main.should == %w{edit_header edit_form}
    layout.edit.form.should == %w{edit_title edit_extended_metadata
                                  edit_content edit_timestamp}
    layout.edit.form_bottom.should == %w{edit_buttons}
    layout.index.should_not be_nil
    layout.index.top.should == %w{help_text}
    layout.index.thead.should == %w{title_header modify_header}
    layout.index.tbody.should == %w{title_cell modify_cell}
    layout.index.bottom.should == %w{new_button}
    
    layout.new.should == layout.edit
  end

  it "should load the default user regions" do
    user = @admin.user
    user.edit.should_not be_nil
    user.edit.main.should == %w{edit_header edit_form}
    user.edit.form.should == %w{edit_name edit_email edit_username
                                edit_password edit_roles edit_notes}
    user.edit.form_bottom.should == %w{edit_timestamp edit_buttons}
    user.index.should_not be_nil
    user.index.thead.should == %w{title_header roles_header modify_header}
    user.index.tbody.should == %w{title_cell roles_cell modify_cell}
    user.index.bottom.should == %w{new_button}
    user.preferences.main.should == %w{edit_header edit_form}
    user.preferences.form.should == %w{edit_password edit_email}
    user.preferences.form_bottom.should == %w{edit_buttons}
    
    user.new.should == user.edit
  end
  
  it "should load the default extension regions" do
    ext = @admin.extension
    ext.index.should_not be_nil
    ext.index.thead.should == %w{title_header website_header version_header}
    ext.index.tbody.should == %w{title_cell website_cell version_cell}
  end
end

describe Radiant::AdminUI::TabSet do

  before :each do
    @tabs = Radiant::AdminUI::TabSet.new
    @tab_names = %w{First Second Third}
    @tab_names.each do |name|
      @tabs.add name, "/#{name.underscore}"
    end
  end

  it "should be Enumerable" do
    @tabs.class.included_modules.should include(Enumerable)
  end

  it "should have its tabs accessible by name using brackets" do
    @tabs.should respond_to(:[])
    @tab_names.each do |name|
      @tabs[name].should be_instance_of(Radiant::AdminUI::Tab)
      @tabs[name].name.should == name
    end
  end

  it "should have its tabs accessible by index using brackets" do
    @tab_names.each_with_index do |name, index|
      @tabs[index].should be_instance_of(Radiant::AdminUI::Tab)
      @tabs[index].name.should == name
    end
  end

  it "should add new tabs to the end by default" do
    @tabs.size.should == 3
    @tabs.add "Test", "/test"
    @tabs[3].name.should == "Test"
  end

  it "should add a new tab before the specified tab" do
    @tabs[1].name.should == "Second"
    @tabs.add "Before", "/before", :before => "Second"
    @tabs[1].name.should == "Before"
    @tabs[2].name.should == "Second"
  end

  it "should add a new tab after the specified tab" do
    @tabs[1].name.should == "Second"
    @tabs[2].name.should == "Third"
    @tabs.add "After", "/after", :after => "Second"
    @tabs[2].name.should == "After"
    @tabs[1].name.should == "Second"
    @tabs[3].name.should == "Third"
  end

  it "should remove a tab by name" do
    @tabs.size.should == 3
    @tabs.remove "Second"
    @tabs.size.should == 2
    @tabs[1].name.should == "Third"
  end

  it "should not allow adding a tab with the same name as an existing tab" do
    lambda { @tabs.add "First", "/first" }.should raise_error(Radiant::AdminUI::DuplicateTabNameError)
  end

  it "should remove all tabs when cleared" do
    @tabs.size.should == 3
    @tabs.clear
    @tabs.size.should == 0
  end
end

describe Radiant::AdminUI::Tab do
  scenario :users

  before :each do
    @tab = Radiant::AdminUI::Tab.new "Test", "/test"
  end

  it "should be shown to all users by default" do
    @tab.visibility.should == [:all]
    [:existing, :another, :admin, :developer, :non_admin].each do |user|
      @tab.should be_shown_for(users(user))
    end
  end

  it "should be shown only to admin users when visibility is admin" do
    @tab.visibility = [:admin]
    @tab.should be_shown_for(users(:admin))
    [:existing, :another, :developer, :non_admin].each do |user|
      @tab.should_not be_shown_for(users(user))
    end
  end

  it "should be shown only to developer users when visibility is developer" do
    @tab.visibility = [:developer]
    @tab.should be_shown_for(users(:developer))
    [:existing, :another, :admin, :non_admin].each do |user|
      @tab.should_not be_shown_for(users(user))
    end
  end

  it "should assign visibility from :for option when created" do
    @tab = Radiant::AdminUI::Tab.new "Test", "/test", :for => :developer
    @tab.visibility.should == [:developer]
  end

  it "should assign visibility from :visibility option when created" do
    @tab = Radiant::AdminUI::Tab.new "Test", "/test", :visibility => :developer
    @tab.visibility.should == [:developer]
  end

  it "should assign visibility from both :for and :visibility options when created" do
    @tab = Radiant::AdminUI::Tab.new "Test", "/test", :for => :developer, :visibility => :admin
    @tab.visibility.should == [:developer, :admin]
  end
end
