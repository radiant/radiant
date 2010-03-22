require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::AdminUI do
  before :each do
    @admin = Radiant::AdminUI.new
  end

  it "should be a Simpleton" do
    Radiant::AdminUI.included_modules.should include(Simpleton)
    Radiant::AdminUI.should respond_to(:instance)
  end

  it "should have a nav structure" do
    @admin.nav.should be_kind_of(Radiant::AdminUI::NavTab)
  end

  it "should create a new nav tab" do
    @admin.nav_tab("Content").should be_kind_of(Radiant::AdminUI::NavTab)
  end
  
  it "should create a new nav item" do
    @admin.nav_item("Foo", "/admin/foo").should be_kind_of(Radiant::AdminUI::NavSubItem)
  end
  
  it "should load the default navigation tabs and sub-items" do
    @admin.load_default_nav
    @admin.nav.should have(3).items
    @admin.nav[:content].should have(1).items
    @admin.nav[:design].should have(2).items
    @admin.nav[:settings].should have(3).items
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
                                edit_page_parts edit_layout_and_type}
    page.edit.parts_bottom.should == %w{}
    page.edit.form_bottom.should == %w{edit_buttons edit_timestamp}
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
    snippet.edit.form.should == %w{edit_title edit_content edit_filter}
    snippet.edit.form_bottom.should == %w{edit_buttons edit_timestamp}
    snippet.index.should_not be_nil
    snippet.index.top.should == %w{}
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
                                  edit_content}
    layout.edit.form_bottom.should == %w{reference_links edit_buttons edit_timestamp}
    layout.index.should_not be_nil
    layout.index.top.should == %w{}
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
                                edit_password edit_roles edit_locale edit_notes}
    user.edit.form_bottom.should == %w{edit_buttons edit_timestamp}
    user.index.should_not be_nil
    user.index.thead.should == %w{title_header roles_header modify_header}
    user.index.tbody.should == %w{title_cell roles_cell modify_cell}
    user.index.bottom.should == %w{new_button}
    user.preferences.main.should == %w{edit_header edit_form}
    user.preferences.form.should == %w{edit_name edit_email edit_username edit_password edit_locale}
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

