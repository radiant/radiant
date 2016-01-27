require File.dirname(__FILE__) + "/../../spec_helper"

describe Radiant::AdminUI do
  before :each do
    @admin = Radiant::AdminUI.new
  end

  it "should be a Simpleton" do
    expect(Radiant::AdminUI.included_modules).to include(Simpleton)
    expect(Radiant::AdminUI).to respond_to(:instance)
  end

  it "should have a nav structure" do
    expect(@admin.nav).to be_kind_of(Radiant::AdminUI::NavTab)
  end

  it "should create a new nav tab" do
    expect(@admin.nav_tab("Content")).to be_kind_of(Radiant::AdminUI::NavTab)
  end
  
  it "should create a new nav item" do
    expect(@admin.nav_item("Foo", "/admin/foo")).to be_kind_of(Radiant::AdminUI::NavSubItem)
  end
  
  it "should load the default navigation tabs and sub-items" do
    @admin.initialize_nav
    expect(@admin.nav.size).to eq(3)
    expect(@admin.nav[:content].size).to eq(1)
    expect(@admin.nav[:design].size).to eq(1)
    expect(@admin.nav[:settings].size).to eq(4)
  end

  it "should have collections of Region Sets for every controller" do
    %w{page layout user}.each do |collection|
      expect(@admin).to respond_to(collection)
      expect(@admin).to respond_to(collection.pluralize)
      expect(@admin.send(collection)).not_to be_nil
      expect(@admin.send(collection)).to be_kind_of(OpenStruct)
    end
  end

  it "should load the default page regions" do
    page = @admin.page
    %w{edit remove children index}.each do |action|
      expect(page.send(action)).not_to be_nil
      expect(page.send(action)).to be_kind_of(Radiant::AdminUI::RegionSet)
    end
    expect(page.edit.main).to eq(%w{edit_header edit_form edit_popups})
    expect(page.edit.form).to eq(%w{edit_title edit_extended_metadata
                                edit_page_parts})
    expect(page.edit.layout).to eq(%w{edit_layout edit_type edit_status
                                  edit_published_at})
    expect(page.edit.parts_bottom).to eq(%w{})
    expect(page.edit.form_bottom).to eq(%w{edit_buttons edit_timestamp})
    expect(page.index.sitemap_head).to eq(%w{title_column_header
                                        status_column_header
                                        actions_column_header})
    expect(page.index.node).to eq(%w{title_column status_column actions_column})
    expect(page.remove).to be === page.index
    expect(page.children).to be === page.index
    expect(page._part).to be === page.edit
    expect(page.new).to be === page.edit
  end

  it "should load the default layout regions" do
    layout = @admin.layout
    expect(layout.edit).not_to be_nil
    expect(layout.edit.main).to eq(%w{edit_header edit_form})
    expect(layout.edit.form).to eq(%w{edit_title edit_extended_metadata
                                  edit_content})
    expect(layout.edit.form_bottom).to eq(%w{reference_links edit_buttons edit_timestamp})
    expect(layout.index).not_to be_nil
    expect(layout.index.top).to eq(%w{})
    expect(layout.index.thead).to eq(%w{title_header actions_header})
    expect(layout.index.tbody).to eq(%w{title_cell actions_cell})
    expect(layout.index.bottom).to eq(%w{new_button})
    
    expect(layout.new).to eq(layout.edit)
  end

  it "should load the default user regions" do
    user = @admin.user
    expect(user.edit).not_to be_nil
    expect(user.edit.main).to eq(%w{edit_header edit_form})
    expect(user.edit.form).to eq(%w{edit_name edit_email edit_username
                                edit_password edit_roles edit_locale edit_notes})
    expect(user.edit.form_bottom).to eq(%w{edit_buttons edit_timestamp})
    expect(user.index).not_to be_nil
    expect(user.index.thead).to eq(%w{title_header roles_header actions_header})
    expect(user.index.tbody).to eq(%w{title_cell roles_cell actions_cell})
    expect(user.index.bottom).to eq(%w{new_button})
    expect(user.preferences.main).to eq(%w{edit_header edit_form})
    expect(user.preferences.form).to eq(%w{edit_name edit_email edit_username edit_password edit_locale})
    expect(user.preferences.form_bottom).to eq(%w{edit_buttons})
    
    expect(user.new).to eq(user.edit)
  end
  
  it "should load the default extension regions" do
    ext = @admin.extension
    expect(ext.index).not_to be_nil
    expect(ext.index.thead).to eq(%w{title_header website_header version_header})
    expect(ext.index.tbody).to eq(%w{title_cell website_cell version_cell})
  end
end

